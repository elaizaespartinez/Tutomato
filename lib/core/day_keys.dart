// Day helpers. Days are stored in Firestore as "yyyy-MM-dd" strings in the
// device's local time zone, which makes "same day?" and "yesterday?" checks
// (streaks, daily totals) simple string comparisons.

String dayKey(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime parseDayKey(String key) {
  final p = key.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

// Calendar-day arithmetic that is safe across daylight-saving changes.
DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

// Weeks start on Monday (the Records chart runs M T W T F S S).
DateTime startOfWeek(DateTime d) => addDays(d, -(d.weekday - 1));

// Whole calendar days from [a] to [b] (negative if b is before a).
int daysBetween(DateTime a, DateTime b) {
  final from = DateTime.utc(a.year, a.month, a.day);
  final to = DateTime.utc(b.year, b.month, b.day);
  return to.difference(from).inDays;
}
