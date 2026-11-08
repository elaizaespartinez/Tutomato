/// A "rhythm" the user can pick on the Start a session screen.
class TimerPreset {
  const TimerPreset(this.name, this.focusMinutes, this.breakMinutes);

  final String name;
  final int focusMinutes;
  final int breakMinutes;

  /// "25 / 5"
  String get label => '$focusMinutes / $breakMinutes';
}

class AppConstants {
  AppConstants._();

  // ---- Timer -------------------------------------------------------------
  static const presets = <TimerPreset>[
    TimerPreset('Classic', 25, 5),
    TimerPreset('Deep work', 50, 10),
    TimerPreset('Quick', 15, 3),
  ];

  static const defaultFocusMinutes = 25;
  static const defaultBreakMinutes = 5;
  static const defaultRounds = 4;
  static const defaultDailyGoalSessions = 4;

  // TODO(team): the README still says "specify the allowed range" for custom
  // durations. These are the limits the backend enforces; change them here.
  // The minimum is 1 so you can test a full session quickly on the emulator.
  static const minFocusMinutes = 1;
  static const maxFocusMinutes = 120;
  static const minBreakMinutes = 1;
  static const maxBreakMinutes = 30;
  static const minRounds = 1;
  static const maxRounds = 8;

  // ---- Tasks -------------------------------------------------------------
  /// "One session = 25 minutes of focus" (Add a task screen).
  static const minutesPerTaskSession = 25;
  static const minTaskSessions = 1;
  static const maxTaskSessions = 20;

  /// Options for the Subject dropdown. TODO(team): confirm the list.
  static const subjects = <String>[
    'Biology',
    'Chemistry',
    'Physics',
    'Mathematics',
    'Computer Science',
    'Literature',
    'History',
    'Languages',
    'Other',
  ];

  // ---- Pomodori character ------------------------------------------------
  /// "+8%" ripeness per completed focus session (Session complete screen).
  static const ripenessPerSession = 8;

  /// Ripeness runs 0..99 and rolls over into the next level at 100.
  static const ripenessPerLevel = 100;

  // ---- Friends -----------------------------------------------------------
  static const inviteCodeLength = 6;
  static const inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  // ---- Auth --------------------------------------------------------------
  static const minPasswordLength = 8;
}
