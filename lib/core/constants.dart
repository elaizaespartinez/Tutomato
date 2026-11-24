import 'package:flutter/material.dart';

/// Light green used for friends and break tips.
const Color kMint = Color(0xFFE8EFD9);

/// How fast the timers run. 1 = real time.
const int kTimerSpeedUp = 1;

/// Study Points earned for each completed focus session.
const int kPointsPerSession = 25;

/// Pomodori ripeness gained per completed focus session (0.08 = 8%).
const double kRipenessPerSession = 0.08;

/// A "rhythm" the user can pick on the Start a session screen.
class TimerPreset {
  const TimerPreset(this.name, this.focusMinutes, this.breakMinutes);

  final String name;
  final int focusMinutes;
  final int breakMinutes;

  /// Compatibility getters for UI code
  int get focus => focusMinutes;
  int get rest => breakMinutes;

  /// "25 / 5"
  String get label => '$focusMinutes / $breakMinutes';
}

/// Alias for UI code compatibility
typedef RhythmPreset = TimerPreset;

const List<TimerPreset> kPresets = [
  TimerPreset('Classic', 25, 5),
  TimerPreset('Deep work', 50, 10),
  TimerPreset('Quick', 15, 3),
];

class AppConstants {
  AppConstants._();

  // ---- Timer -------------------------------------------------------------
  static const presets = kPresets;

  static const defaultFocusMinutes = 25;
  static const defaultBreakMinutes = 5;
  static const defaultRounds = 4;
  static const defaultDailyGoalSessions = 4;

  static const minFocusMinutes = 1;
  static const maxFocusMinutes = 120;
  static const minBreakMinutes = 1;
  static const maxBreakMinutes = 30;
  static const minRounds = 1;
  static const maxRounds = 8;

  // ---- Tasks -------------------------------------------------------------
  static const minutesPerTaskSession = 25;
  static const minTaskSessions = 1;
  static const maxTaskSessions = 20;

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
  static const ripenessPerSession = 8;
  static const ripenessPerLevel = 100;

  // ---- Friends -----------------------------------------------------------
  static const inviteCodeLength = 6;
  static const inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  // ---- Auth --------------------------------------------------------------
  static const minPasswordLength = 8;
}