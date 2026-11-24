import 'package:tutomato/core/constants.dart';
import 'package:tutomato/logic/rewards.dart';
import 'package:tutomato/models/session_result.dart';
import 'package:tutomato/models/user_profile.dart';

/// Which timer screen to show.
enum TimerPhase {
  /// No timer running: Home / Start a session.
  idle,

  /// "Focus session" screen, counting down, lock-in active.
  focus,

  /// "Your little win" screen (session complete).
  focusComplete,

  /// "A little breather" screen (short break).
  breakTime,

  /// "A fresh start" screen (lock-in broken).
  broken,
}

/// Pick your rhythm / Or make it yours.
class TimerConfig {
  const TimerConfig({
    required this.focusMinutes,
    required this.breakMinutes,
    required this.rounds,
  });

  factory TimerConfig.fromSettings(TimerSettings s) => TimerConfig(
        focusMinutes: s.focusMinutes,
        breakMinutes: s.breakMinutes,
        rounds: s.rounds,
      );

  factory TimerConfig.fromPreset(TimerPreset p,
          {int rounds = AppConstants.defaultRounds}) =>
      TimerConfig(
        focusMinutes: p.focusMinutes,
        breakMinutes: p.breakMinutes,
        rounds: rounds,
      );

  final int focusMinutes;
  final int breakMinutes;
  final int rounds;

  /// Null when valid, otherwise a message to show.
  String? validate() {
    if (focusMinutes < AppConstants.minFocusMinutes ||
        focusMinutes > AppConstants.maxFocusMinutes) {
      return 'Focus time must be ${AppConstants.minFocusMinutes}'
          '-${AppConstants.maxFocusMinutes} minutes.';
    }
    if (breakMinutes < AppConstants.minBreakMinutes ||
        breakMinutes > AppConstants.maxBreakMinutes) {
      return 'Break time must be ${AppConstants.minBreakMinutes}'
          '-${AppConstants.maxBreakMinutes} minutes.';
    }
    if (rounds < AppConstants.minRounds || rounds > AppConstants.maxRounds) {
      return 'Rounds must be ${AppConstants.minRounds}-${AppConstants.maxRounds}.';
    }
    return null;
  }

  TimerConfig copyWith({int? focusMinutes, int? breakMinutes, int? rounds}) =>
      TimerConfig(
        focusMinutes: focusMinutes ?? this.focusMinutes,
        breakMinutes: breakMinutes ?? this.breakMinutes,
        rounds: rounds ?? this.rounds,
      );
}

/// Everything the timer screens need, in one immutable snapshot.
class TimerState {
  const TimerState({
    required this.phase,
    required this.config,
    required this.round,
    required this.total,
    required this.remaining,
    this.paused = false,
    this.taskId,
    this.taskTitle = 'Free study',
    this.subject,
    this.sessionId,
    this.reward,
    this.broken,
    this.errorMessage,
  });

  factory TimerState.idle() => const TimerState(
        phase: TimerPhase.idle,
        config: TimerConfig(
          focusMinutes: AppConstants.defaultFocusMinutes,
          breakMinutes: AppConstants.defaultBreakMinutes,
          rounds: AppConstants.defaultRounds,
        ),
        round: 0,
        total: Duration.zero,
        remaining: Duration.zero,
      );

  final TimerPhase phase;
  final TimerConfig config;

  /// 1-based: "Round 1 of 4".
  final int round;

  /// Length of the current focus or break, and what is left of it.
  final Duration total;
  final Duration remaining;

  /// Only used on the break screen ("Pause break").
  final bool paused;

  final String? taskId;
  final String taskTitle;
  final String? subject;
  final String? sessionId;

  /// Set on [TimerPhase.focusComplete] once the points have been saved. While
  /// it is still null (and [errorMessage] is null) show a spinner.
  final SessionReward? reward;

  /// Set on [TimerPhase.broken].
  final BrokenSession? broken;

  /// Set if saving the finished session failed.
  final String? errorMessage;

  bool get isFinalRound => round >= config.rounds;

  /// "+25 Study Points when you finish"
  int get pointsOnFinish => pointsForFocusMinutes(config.focusMinutes);

  /// 0.0 -> 1.0 for the progress ring.
  double get progress => total.inMilliseconds == 0
      ? 0.0
      : (1 - remaining.inMilliseconds / total.inMilliseconds)
          .clamp(0.0, 1.0)
          .toDouble();

  bool get breakFinished =>
      phase == TimerPhase.breakTime && remaining == Duration.zero;

  /// "Start 5-minute break"
  int get breakMinutes => config.breakMinutes;

  TimerState copyWith({
    TimerPhase? phase,
    Duration? total,
    Duration? remaining,
    bool? paused,
    SessionReward? reward,
    BrokenSession? broken,
    String? errorMessage,
  }) =>
      TimerState(
        phase: phase ?? this.phase,
        config: config,
        round: round,
        total: total ?? this.total,
        remaining: remaining ?? this.remaining,
        paused: paused ?? this.paused,
        taskId: taskId,
        taskTitle: taskTitle,
        subject: subject,
        sessionId: sessionId,
        reward: reward ?? this.reward,
        broken: broken ?? this.broken,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
