/// A study task shown in "To Learn".
class Task {
  final String id;
  String name;
  String subject;
  DateTime due;
  int sessions; // planned focus sessions
  int sessionsDone;
  bool done;

  Task({
    required this.id,
    required this.name,
    required this.subject,
    required this.due,
    this.sessions = 1,
    this.sessionsDone = 0,
    this.done = false,
  });

  /// "1 / 3 sessions"
  String get progress =>
      '$sessionsDone / $sessions ${sessions == 1 ? 'session' : 'sessions'}';
}

/// One finished focus session (shown in Records).
class SessionLog {
  final String subject;
  final int minutes;
  final DateTime at;
  const SessionLog({
    required this.subject,
    required this.minutes,
    required this.at,
  });
}

enum WardrobeCategory { outfit, color, extra }

/// Something Pip can wear or be coloured with.
class WardrobeItem {
  final String id; // e.g. "outfit_scholar"
  final WardrobeCategory category;
  final String name;
  final int cost;
  const WardrobeItem(this.id, this.category, this.name, this.cost);

  /// "scholar" (the part after the underscore)
  String get key => id.substring(id.indexOf('_') + 1);
}

/// A friend in the study circle (sample data until there is an online backend).
class Friend {
  final String name;
  final int sharedStreak;
  final String status;
  final bool focusing;
  const Friend({
    required this.name,
    required this.sharedStreak,
    required this.status,
    required this.focusing,
  });
}
