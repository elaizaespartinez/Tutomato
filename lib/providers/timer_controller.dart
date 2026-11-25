import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutomato/core/app_exception.dart';
import 'package:tutomato/core/async_utils.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/logic/timer_state.dart';
import 'package:tutomato/models/session_result.dart';
import 'package:tutomato/models/study_task.dart';
import 'package:tutomato/providers/core_providers.dart';
import 'package:tutomato/providers/data_providers.dart';
import 'package:tutomato/services/lock_in_service.dart';

class TimerController extends Notifier<TimerState> {
  Timer? _ticker;
  DateTime? _endsAt;
  final LockInService _lockIn = LockInService();

  DateTime _now() => ref.read(clockProvider)();

  @override
  TimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _lockIn.stop();
    });
    ref.listen(userProfileProvider, (previous, next) {});
    return TimerState.idle();
  }

  // ---- Start ---------------------------------------------------------------

  Future<void> startFocus({required TimerConfig config, StudyTask? task}) async {
    final uid = _requireUid();
    if (state.phase == TimerPhase.focus) return;
    final problem = config.validate();
    if (problem != null) throw AppException(problem);

    _beginFocusRound(
      uid: uid,
      config: config,
      round: 1,
      taskId: task?.id,
      taskTitle: task?.title ?? 'Free study',
      subject: task?.subject,
    );
  }

  Future<void> retry() async {
    if (state.phase != TimerPhase.broken) return;
    _beginFocusRound(
      uid: _requireUid(),
      config: state.config,
      round: state.round,
      taskId: state.taskId,
      taskTitle: state.taskTitle,
      subject: state.subject,
    );
  }

  Future<void> startNextFocus() async {
    final phase = state.phase;
    if (phase != TimerPhase.breakTime && phase != TimerPhase.focusComplete) return;
    if (state.isFinalRound) return;
    _beginFocusRound(
      uid: _requireUid(),
      config: state.config,
      round: state.round + 1,
      taskId: state.taskId,
      taskTitle: state.taskTitle,
      subject: state.subject,
    );
  }

  void _beginFocusRound({
    required String uid,
    required TimerConfig config,
    required int round,
    required String? taskId,
    required String taskTitle,
    required String? subject,
  }) {
    _stopTicker();
    final now = _now();
    final total = Duration(minutes: config.focusMinutes);

    final sessionId = ref.read(sessionRepositoryProvider).startFocus(
          uid: uid,
          taskId: taskId,
          taskTitle: taskTitle,
          subject: subject,
          plannedMinutes: config.focusMinutes,
          round: round,
          totalRounds: config.rounds,
          startedAt: now,
        );

    _endsAt = now.add(total);
    state = TimerState(
      phase: TimerPhase.focus,
      config: config,
      round: round,
      total: total,
      remaining: total,
      taskId: taskId,
      taskTitle: taskTitle,
      subject: subject,
      sessionId: sessionId,
    );
    _startTicker();
    _lockIn.start(_onLeftApp);
  }

  // ---- During focus --------------------------------------------------------

  void endSession() {
    if (state.phase == TimerPhase.focus) _breakSession(BreakReason.endedEarly);
  }

  void _onLeftApp() {
    if (state.phase == TimerPhase.focus) _breakSession(BreakReason.leftApp);
  }

  void _breakSession(BreakReason reason) {
    final uid = ref.read(currentUidProvider);
    final sessionId = state.sessionId;
    final remaining = _remaining();
    _stopTicker();
    _lockIn.stop();

    if (uid != null && sessionId != null) {
      ref.read(sessionRepositoryProvider).markBroken(
            uid: uid,
            sessionId: sessionId,
            remaining: remaining,
            reason: reason,
            now: _now(),
          );
    }

    final profile = ref.read(userProfileProvider).dataOrNull;
    final today = dayKey(_now());
    state = state.copyWith(
      phase: TimerPhase.broken,
      remaining: remaining,
      broken: BrokenSession(
        reason: reason,
        remaining: remaining,
        pointsBalance: profile?.points ?? 0,
        currentStreak: profile?.streakOn(today) ?? 0,
        todaySessions: profile?.sessionsOn(today) ?? 0,
      ),
    );
  }

  // ---- Completion ----------------------------------------------------------

  Future<void> _notifyTimerEnded() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/alarm.mp3'));
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
    try {
      await HapticFeedback.vibrate();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  Future<void> _completeFocus() async {
    _lockIn.stop();

    // Distinct double vibration pulse and loud alarm audio feedback
    unawaited(_notifyTimerEnded());

    final uid = ref.read(currentUidProvider);
    final snapshot = state;
    final sessionId = snapshot.sessionId;

    if (uid != null && sessionId != null) {
      try {
        final reward = await ref.read(sessionRepositoryProvider).completeFocus(
              uid: uid,
              sessionId: sessionId,
              minutes: snapshot.config.focusMinutes,
              taskId: snapshot.taskId,
              now: _now(),
            );
        state = state.copyWith(reward: reward);
        unawaited(_updateSharedStreaks(uid));
      } catch (e) {
        debugPrint('Could not save finished session: $e');
      }
    }

    // Automatically enter rest mode if not the final round, else show "All rounds done!" win screen
    if (!snapshot.isFinalRound) {
      startBreak();
    } else {
      state = snapshot.copyWith(
        phase: TimerPhase.focusComplete,
        remaining: Duration.zero,
      );
    }
  }

  Future<void> _updateSharedStreaks(String uid) async {
    try {
      await ref
          .read(friendRepositoryProvider)
          .onSessionCompleted(myUid: uid, now: _now());
    } catch (e) {
      debugPrint('Shared streak update skipped: $e');
    }
  }

  Future<void> setTaskDone(bool done) async {
    final uid = ref.read(currentUidProvider);
    final taskId = state.taskId;
    if (uid == null || taskId == null) return;
    await ref.read(taskRepositoryProvider).setDone(uid, taskId, done);
  }

  // ---- Breaks --------------------------------------------------------------

  void startBreak() {
    final total = Duration(minutes: state.config.breakMinutes);
    _endsAt = _now().add(total);
    state = state.copyWith(
      phase: TimerPhase.breakTime,
      total: total,
      remaining: total,
      paused: false,
    );
    _startTicker();
  }

  void pauseBreak() {
    if (state.phase != TimerPhase.breakTime || state.paused) return;
    final remaining = _remaining();
    _stopTicker();
    state = state.copyWith(remaining: remaining, paused: true);
  }

  void resumeBreak() {
    if (state.phase != TimerPhase.breakTime || !state.paused) return;
    _endsAt = _now().add(state.remaining);
    state = state.copyWith(paused: false);
    _startTicker();
  }

  // ---- Leaving the flow ----------------------------------------------------

  void reset() {
    _stopTicker();
    _lockIn.stop();
    _endsAt = null;
    state = TimerState.idle();
  }

  // ---- Internals -----------------------------------------------------------

  String _requireUid() {
    final uid = ref.read(currentUidProvider);
    if (uid == null) throw const AppException('Please log in first.');
    return uid;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Duration _remaining() {
    final end = _endsAt;
    if (end == null) return Duration.zero;
    final left = end.difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  void _tick() {
    final remaining = _remaining();
    if (remaining > Duration.zero) {
      state = state.copyWith(remaining: remaining);
      return;
    }
    _stopTicker();
    switch (state.phase) {
      case TimerPhase.focus:
        _completeFocus();
      case TimerPhase.breakTime:
        unawaited(_notifyTimerEnded());
        state = state.copyWith(remaining: Duration.zero);
      default:
        break;
    }
  }
}

final timerControllerProvider =
    NotifierProvider<TimerController, TimerState>(TimerController.new);