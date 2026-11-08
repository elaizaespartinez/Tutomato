import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/models/study_session.dart';

/// Numbers for the Records screen for one week (Monday to Sunday).
class WeeklyStats {
  const WeeklyStats({
    required this.weekStart,
    required this.totalMinutes,
    required this.sessionsCompleted,
    required this.minutesPerDay,
    required this.todaySessions,
  });

  final DateTime weekStart;

  /// "6h 15m" Focus time (use formatMinutes).
  final int totalMinutes;

  /// "15" Sessions completed.
  final int sessionsCompleted;

  /// 7 values, Monday..Sunday, for the "A week of showing up" bars.
  final List<int> minutesPerDay;

  /// "Today's sessions" list (empty when the selected week isn't this week).
  final List<StudySession> todaySessions;

  int get maxDayMinutes =>
      minutesPerDay.fold(0, (m, v) => v > m ? v : m);
}

/// Only completed sessions count; broken and cancelled ones never appear.
WeeklyStats buildWeeklyStats(
  List<StudySession> sessions, {
  required DateTime weekStart,
  required DateTime today,
}) {
  final perDay = List<int>.filled(7, 0);
  final todayList = <StudySession>[];
  var total = 0;
  var count = 0;
  final todayKey = dayKey(today);

  for (final s in sessions) {
    if (!s.isCompleted) continue;
    final index = daysBetween(weekStart, s.startedAt);
    if (index < 0 || index > 6) continue;
    perDay[index] += s.plannedMinutes;
    total += s.plannedMinutes;
    count++;
    if (dayKey(s.startedAt) == todayKey) todayList.add(s);
  }
  todayList.sort((a, b) => a.startedAt.compareTo(b.startedAt));

  return WeeklyStats(
    weekStart: weekStart,
    totalMinutes: total,
    sessionsCompleted: count,
    minutesPerDay: perDay,
    todaySessions: todayList,
  );
}
