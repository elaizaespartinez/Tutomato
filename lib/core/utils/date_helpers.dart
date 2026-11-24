const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "2026-11-05", used as the day id stored in Firestore.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

/// 0 = today, 1 = tomorrow, -1 = yesterday.
int daysFromToday(DateTime d) {
  final now = DateTime.now();
  return DateTime.utc(
    d.year,
    d.month,
    d.day,
  ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
}

String _dateText(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

/// "Today", "Tomorrow", "Overdue" or "Mon, Nov 16".
String shortDue(DateTime d) {
  final n = daysFromToday(d);
  if (n == 0) return 'Today';
  if (n == 1) return 'Tomorrow';
  if (n < 0) return 'Overdue';
  return _dateText(d);
}

/// For the To Learn cards: "Due today", "Tomorrow", "Mon, Nov 16".
String dueMeta(DateTime d) => daysFromToday(d) == 0 ? 'Due today' : shortDue(d);

/// For the Add a task field: "Today · Thu, Nov 5".
String dueField(DateTime d) {
  final n = daysFromToday(d);
  if (n == 0) return 'Today · ${_dateText(d)}';
  if (n == 1) return 'Tomorrow · ${_dateText(d)}';
  return _dateText(d);
}

/// 9:05 AM
String timeLabel(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
}

/// "Nov 2–8" or "Nov 30–Dec 6".
String weekRangeLabel(DateTime now) {
  final start = dayOnly(now).subtract(Duration(days: now.weekday - 1));
  final end = start.add(const Duration(days: 6));
  final first = '${_months[start.month - 1]} ${start.day}';
  final second = start.month == end.month
      ? '${end.day}'
      : '${_months[end.month - 1]} ${end.day}';
  return '$first–$second';
}

/// 1125 seconds -> "18:45"
String mmss(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final m = (s ~/ 60).toString().padLeft(2, '0');
  final r = (s % 60).toString().padLeft(2, '0');
  return '$m:$r';
}

/// 375 minutes -> "6h 15m"
String hoursMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return h == 0 ? '${m}m' : '${h}h ${m}m';
}
