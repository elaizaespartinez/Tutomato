import 'package:tutomato/core/day_keys.dart';

const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _monthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Countdown text, "18:42". Rounds up so the clock never shows 00:00 early.
String formatClock(Duration d) {
  final totalSeconds = (d.inMilliseconds + 999) ~/ 1000;
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// "50 min", "6h 15m", "2h".
String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

/// "0 / 2 sessions", "0 / 1 session".
String sessionsLabel(int done, int planned) =>
    '$done / $planned session${planned == 1 ? '' : 's'}';

/// "Today", "Tomorrow", "Overdue" or "Thu, Nov 5".
String dueLabel(String dueDay, String today) {
  if (dueDay == today) return 'Today';
  final diff = daysBetween(parseDayKey(today), parseDayKey(dueDay));
  if (diff == 1) return 'Tomorrow';
  if (diff < 0) return 'Overdue';
  final due = parseDayKey(dueDay);
  return '${_weekdaysShort[due.weekday - 1]}, '
      '${_monthsShort[due.month - 1]} ${due.day}';
}

/// "Today · Thu, Nov 5" for the Add a task date field.
String dueDateFieldLabel(DateTime due, DateTime now) {
  final full = '${_weekdaysShort[due.weekday - 1]}, '
      '${_monthsShort[due.month - 1]} ${due.day}';
  return dayKey(due) == dayKey(now) ? 'Today · $full' : full;
}

/// "Nov 2–8", or "Oct 28 – Nov 3" when the week crosses a month.
String weekRangeLabel(DateTime weekStart) {
  final end = addDays(weekStart, 6);
  final a = _monthsShort[weekStart.month - 1];
  final b = _monthsShort[end.month - 1];
  if (weekStart.month == end.month) return '$a ${weekStart.day}–${end.day}';
  return '$a ${weekStart.day} – $b ${end.day}';
}

/// "9:00 AM"
String formatTimeOfDay(DateTime t) {
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final suffix = t.hour < 12 ? 'AM' : 'PM';
  return '$h12:${t.minute.toString().padLeft(2, '0')} $suffix';
}

/// "Growing since October"
String growingSinceLabel(DateTime createdAt) =>
    'Growing since ${_monthsFull[createdAt.month - 1]}';
