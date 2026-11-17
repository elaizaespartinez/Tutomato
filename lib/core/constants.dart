import 'package:flutter/material.dart';

/// How fast the timers run. 1 = real time.
/// While testing, set it to 60 so one real second counts as one minute.
const int kTimerSpeedUp = 1;

/// Study Points earned for each completed focus session.
const int kPointsPerSession = 25;

/// Pomodori ripeness gained per completed focus session (0.08 = 8%).
const double kRipenessPerSession = 0.08;

/// Light green used for friends and break tips.
const Color kMint = Color(0xFFE8EFD9);

/// The three ready-made timer rhythms.
class RhythmPreset {
  final int focus;
  final int rest;
  final String name;
  const RhythmPreset(this.focus, this.rest, this.name);
}

const List<RhythmPreset> kPresets = [
  RhythmPreset(25, 5, 'Classic'),
  RhythmPreset(50, 10, 'Deep work'),
  RhythmPreset(15, 3, 'Quick'),
];
