import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/core/constants.dart';
import 'package:tutomato/logic/streak.dart';
import 'package:tutomato/models/converters.dart';
import 'package:tutomato/models/shop_item.dart';

/// Timer preferences + daily goal + sound (Profile > "Make it yours").
class TimerSettings {
  const TimerSettings({
    this.focusMinutes = AppConstants.defaultFocusMinutes,
    this.breakMinutes = AppConstants.defaultBreakMinutes,
    this.rounds = AppConstants.defaultRounds,
    this.dailyGoalSessions = AppConstants.defaultDailyGoalSessions,
    this.soundEnabled = true,
    this.remindersEnabled = true,
  });

  final int focusMinutes;
  final int breakMinutes;
  final int rounds;
  final int dailyGoalSessions;
  final bool soundEnabled;
  final bool remindersEnabled;

  /// "25 / 5 min" (Profile > Timer preferences subtitle).
  String get summary => '$focusMinutes / $breakMinutes min';

  factory TimerSettings.fromMap(Object? raw) {
    final m = raw is Map ? raw : const {};
    return TimerSettings(
      focusMinutes: readInt(m['focusMinutes'], AppConstants.defaultFocusMinutes),
      breakMinutes: readInt(m['breakMinutes'], AppConstants.defaultBreakMinutes),
      rounds: readInt(m['rounds'], AppConstants.defaultRounds),
      dailyGoalSessions:
          readInt(m['dailyGoalSessions'], AppConstants.defaultDailyGoalSessions),
      soundEnabled: readBool(m['soundEnabled'], true),
      remindersEnabled: readBool(m['remindersEnabled'], true),
    );
  }

  Map<String, dynamic> toMap() => {
        'focusMinutes': focusMinutes,
        'breakMinutes': breakMinutes,
        'rounds': rounds,
        'dailyGoalSessions': dailyGoalSessions,
        'soundEnabled': soundEnabled,
        'remindersEnabled': remindersEnabled,
      };

  TimerSettings copyWith({
    int? focusMinutes,
    int? breakMinutes,
    int? rounds,
    int? dailyGoalSessions,
    bool? soundEnabled,
    bool? remindersEnabled,
  }) =>
      TimerSettings(
        focusMinutes: focusMinutes ?? this.focusMinutes,
        breakMinutes: breakMinutes ?? this.breakMinutes,
        rounds: rounds ?? this.rounds,
        dailyGoalSessions: dailyGoalSessions ?? this.dailyGoalSessions,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      );
}

/// What the Pomodori is currently wearing: one item per category.
class EquippedItems {
  const EquippedItems({
    this.outfit = ShopCatalog.defaultOutfitId,
    this.color = ShopCatalog.defaultColorId,
    this.extra = ShopCatalog.defaultExtraId,
  });

  final String outfit;
  final String color;
  final String extra;

  String idFor(ShopCategory category) => switch (category) {
        ShopCategory.outfit => outfit,
        ShopCategory.color => color,
        ShopCategory.extra => extra,
      };

  EquippedItems withItem(ShopItem item) => switch (item.category) {
        ShopCategory.outfit => EquippedItems(outfit: item.id, color: color, extra: extra),
        ShopCategory.color => EquippedItems(outfit: outfit, color: item.id, extra: extra),
        ShopCategory.extra => EquippedItems(outfit: outfit, color: color, extra: item.id),
      };

  factory EquippedItems.fromMap(Object? raw) {
    final m = raw is Map ? raw : const {};
    return EquippedItems(
      outfit: readString(m['outfit'], ShopCatalog.defaultOutfitId),
      color: readString(m['color'], ShopCatalog.defaultColorId),
      extra: readString(m['extra'], ShopCatalog.defaultExtraId),
    );
  }

  Map<String, dynamic> toMap() =>
      {'outfit': outfit, 'color': color, 'extra': extra};
}

/// Everything about the signed-in user: users/{uid}.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.createdAt,
    required this.points,
    required this.level,
    required this.ripeness,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActiveDay,
    required this.todayDay,
    required this.todayMinutes,
    required this.todaySessions,
    required this.totalSessions,
    required this.totalFocusMinutes,
    required this.equipped,
    required this.ownedItemIds,
    required this.settings,
    required this.inviteCode,
  });

  final String uid;
  final String displayName;
  final String email;
  final DateTime createdAt;

  /// Study Points balance.
  final int points;

  /// "Level 3 · Ripeness 38%"
  final int level;
  final int ripeness;

  final int currentStreak;
  final int bestStreak;

  /// "yyyy-MM-dd" of the last day with a completed focus session.
  final String? lastActiveDay;

  /// Denormalised "today" counters. They belong to [todayDay]; once the date
  /// changes use [minutesOn] / [sessionsOn], which return 0 for other days.
  final String? todayDay;
  final int todayMinutes;
  final int todaySessions;

  final int totalSessions;
  final int totalFocusMinutes;

  final EquippedItems equipped;
  final List<String> ownedItemIds;
  final TimerSettings settings;

  /// Short code a friend types to add this user.
  final String inviteCode;

  /// Streak to display today. A streak that missed yesterday shows as 0.
  int streakOn(String today) => effectiveStreak(
        current: currentStreak,
        lastDay: lastActiveDay,
        today: today,
      );

  int minutesOn(String today) => todayDay == today ? todayMinutes : 0;
  int sessionsOn(String today) => todayDay == today ? todaySessions : 0;
  bool focusedOn(String today) => lastActiveDay == today;

  bool owns(String itemId) =>
      ownedItemIds.contains(itemId) || (ShopCatalog.byId(itemId)?.isFree ?? false);

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final owned = d['ownedItemIds'];
    return UserProfile(
      uid: doc.id,
      displayName: readString(d['displayName']),
      email: readString(d['email']),
      createdAt: readDate(d['createdAt']) ?? DateTime.now(),
      points: readInt(d['points']),
      level: readInt(d['level'], 1),
      ripeness: readInt(d['ripeness']),
      currentStreak: readInt(d['currentStreak']),
      bestStreak: readInt(d['bestStreak']),
      lastActiveDay: readStringOrNull(d['lastActiveDay']),
      todayDay: readStringOrNull(d['todayDay']),
      todayMinutes: readInt(d['todayMinutes']),
      todaySessions: readInt(d['todaySessions']),
      totalSessions: readInt(d['totalSessions']),
      totalFocusMinutes: readInt(d['totalFocusMinutes']),
      equipped: EquippedItems.fromMap(d['equipped']),
      ownedItemIds: owned is List
          ? owned.whereType<String>().toList()
          : ShopCatalog.defaultOwnedIds,
      settings: TimerSettings.fromMap(d['settings']),
      inviteCode: readString(d['inviteCode']),
    );
  }
}
