import 'dart:math' as math;

import 'package:tutomato/core/day_keys.dart';

/// A streak counts consecutive days with at least one completed focus session.
/// The same rules drive the personal streak and the shared (friend) streak.
class StreakState {
  const StreakState({
    required this.current,
    required this.best,
    required this.lastDay,
  });

  final int current;
  final int best;

  /// "yyyy-MM-dd" of the last day that counted, or null if never.
  final String? lastDay;
}

/// Call when a session completes on [today] ("yyyy-MM-dd").
///  - already counted today -> unchanged
///  - last counted yesterday -> streak + 1
///  - anything else          -> a fresh streak of 1
StreakState advanceStreak(StreakState s, String today) {
  if (s.lastDay == today) return s;
  final yesterday = dayKey(addDays(parseDayKey(today), -1));
  final next = s.lastDay == yesterday ? s.current + 1 : 1;
  return StreakState(
    current: next,
    best: math.max(s.best, next),
    lastDay: today,
  );
}

/// The streak to *display* today. A stored streak whose last day is older than
/// yesterday has already been lost, so it shows as 0 until the next session.
int effectiveStreak({
  required int current,
  required String? lastDay,
  required String today,
}) {
  if (lastDay == null) return 0;
  final yesterday = dayKey(addDays(parseDayKey(today), -1));
  return (lastDay == today || lastDay == yesterday) ? current : 0;
}
