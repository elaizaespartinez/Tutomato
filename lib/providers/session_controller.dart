import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/models.dart';
import 'app_state.dart';

enum SessionPhase { idle, focus, rest, complete, broken }

/// Runs one Pomodoro session: focus -> complete -> break -> next focus...
/// The four session screens all read from this one object.
class SessionController extends ChangeNotifier {
  SessionController._();
  static final SessionController instance = SessionController._();

  // Settings chosen on the "Start a session" screen
  int focusMinutes = 25;
  int breakMinutes = 5;
  int rounds = 4;
  String? taskId;

  // Live state
  SessionPhase phase = SessionPhase.idle;
  int round = 1;
  int remaining = 0; // seconds left in the current phase
  int total = 0; // seconds in the current phase
  bool paused = false;
  int leftWith = 0; // seconds that were left when the lock-in broke
  int earnedPoints = 0;
  double earnedRipeness = 0;
  Timer? _timer;

  Task? get task => taskId == null ? null : AppState.instance.taskById(taskId!);
  bool get isLastRound => round >= rounds;
  double get progress => total == 0 ? 0 : 1 - remaining / total;
  bool get restOver => phase == SessionPhase.rest && remaining <= 0;

  void start({
    required int focus,
    required int rest,
    required int rounds,
    String? taskId,
  }) {
    focusMinutes = focus;
    breakMinutes = rest;
    this.rounds = rounds;
    this.taskId = taskId;
    round = 1;
    _beginFocus();
  }

  void _beginFocus() {
    phase = SessionPhase.focus;
    total = remaining = focusMinutes * 60;
    paused = false;
    _run();
    notifyListeners();
  }

  void _run() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (paused) return;
    remaining -= kTimerSpeedUp;
    if (remaining <= 0) {
      remaining = 0;
      _timer?.cancel();
      if (phase == SessionPhase.focus) _finishFocus();
    }
    notifyListeners();
  }

  void _finishFocus() {
    AppState.instance.recordSession(task: task, minutes: focusMinutes);
    earnedPoints = kPointsPerSession;
    earnedRipeness = kRipenessPerSession;
    phase = SessionPhase.complete;
  }

  void startBreak() {
    phase = SessionPhase.rest;
    total = remaining = breakMinutes * 60;
    paused = false;
    _run();
    notifyListeners();
  }

  void startNextFocus() {
    round += 1;
    _beginFocus();
  }

  void togglePause() {
    paused = !paused;
    notifyListeners();
  }

  /// Lock-in broken: the user left the app or ended the session early.
  void breakLock() {
    if (phase != SessionPhase.focus) return;
    _timer?.cancel();
    leftWith = remaining;
    phase = SessionPhase.broken;
    notifyListeners();
  }

  /// Stops everything without notifying (used when a screen closes).
  void reset() {
    _timer?.cancel();
    phase = SessionPhase.idle;
    paused = false;
  }
}
