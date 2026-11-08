/// What the "Session complete!" screen shows.
class SessionReward {
  const SessionReward({
    required this.sessionId,
    required this.minutes,
    required this.pointsEarned,
    required this.totalPoints,
    required this.ripenessGain,
    required this.level,
    required this.ripeness,
    required this.leveledUp,
    required this.currentStreak,
    required this.bestStreak,
    required this.todaySessions,
    required this.todayMinutes,
    required this.taskId,
  });

  final String sessionId;
  final int minutes;

  /// "+25"
  final int pointsEarned;

  /// "265 points total"
  final int totalPoints;

  /// "+8%"
  final int ripenessGain;

  /// "Pip is 46% ripe" -> [ripeness]; [level] only changes on a level-up.
  final int level;
  final int ripeness;
  final bool leveledUp;

  /// "Daily streak: 5 days"
  final int currentStreak;
  final int bestStreak;

  final int todaySessions;
  final int todayMinutes;

  /// The task this session was for, so the "Mark as done" checkbox knows
  /// what to update. Null for free study.
  final String? taskId;
}

enum BreakReason {
  /// The app went to the background (home button, another app, screen off).
  leftApp,

  /// The user pressed "End session".
  endedEarly,
}

/// What the "Lock-in broken" screen shows.
class BrokenSession {
  const BrokenSession({
    required this.reason,
    required this.remaining,
    required this.pointsBalance,
    required this.currentStreak,
    required this.todaySessions,
  });

  final BreakReason reason;

  /// "You left with 18:42 still on the timer"
  final Duration remaining;

  /// Balance is unchanged: "240 points · unchanged". Points are never removed.
  final int pointsBalance;

  /// "Your 5-day streak is safe"
  final int currentStreak;

  /// "You already completed 2 sessions today."
  final int todaySessions;

  /// The streak is only "safe" if the user already has a session today, or the
  /// streak is still alive from yesterday (it hasn't been lost by this break).
  bool get streakIsSafe => currentStreak > 0;
}
