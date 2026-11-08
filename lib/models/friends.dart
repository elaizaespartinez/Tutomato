import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/logic/streak.dart';
import 'package:tutomato/models/converters.dart';
import 'package:tutomato/models/user_profile.dart';

/// The small, friend-visible part of a user: publicProfiles/{uid}.
/// Never contains email, points or tasks.
class PublicProfile {
  const PublicProfile({
    required this.uid,
    required this.displayName,
    required this.equipped,
    required this.level,
    required this.lastActiveDay,
    required this.todayDay,
    required this.todayMinutes,
    required this.focusingUntil,
    required this.inviteCode,
  });

  final String uid;
  final String displayName;
  final EquippedItems equipped;
  final int level;
  final String? lastActiveDay;
  final String? todayDay;
  final int todayMinutes;

  /// Set while a focus session runs. "Focusing now" = this is in the future.
  /// (A timestamp rather than a bool so a crash can't leave someone stuck as
  /// "focusing" forever.)
  final DateTime? focusingUntil;
  final String inviteCode;

  bool isFocusing(DateTime now) =>
      focusingUntil != null && focusingUntil!.isAfter(now);
  bool focusedOn(String day) => lastActiveDay == day;
  int minutesOn(String day) => todayDay == day ? todayMinutes : 0;

  factory PublicProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return PublicProfile(
      uid: doc.id,
      displayName: readString(d['displayName'], 'Student'),
      equipped: EquippedItems.fromMap(d['equipped']),
      level: readInt(d['level'], 1),
      lastActiveDay: readStringOrNull(d['lastActiveDay']),
      todayDay: readStringOrNull(d['todayDay']),
      todayMinutes: readInt(d['todayMinutes']),
      focusingUntil: readDate(d['focusingUntil']),
      inviteCode: readString(d['inviteCode']),
    );
  }
}

/// A shared streak between two users: friendships/{uidA_uidB}.
class Friendship {
  const Friendship({
    required this.id,
    required this.members,
    required this.sharedStreak,
    required this.bestSharedStreak,
    required this.lastSharedDay,
    required this.createdAt,
  });

  final String id;
  final List<String> members;
  final int sharedStreak;
  final int bestSharedStreak;

  /// Last day BOTH friends completed a session.
  final String? lastSharedDay;
  final DateTime createdAt;

  String otherUid(String me) =>
      members.firstWhere((m) => m != me, orElse: () => me);

  int streakOn(String today) => effectiveStreak(
        current: sharedStreak,
        lastDay: lastSharedDay,
        today: today,
      );

  factory Friendship.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final members = d['members'];
    return Friendship(
      id: doc.id,
      members: members is List ? members.whereType<String>().toList() : const [],
      sharedStreak: readInt(d['sharedStreak']),
      bestSharedStreak: readInt(d['bestSharedStreak']),
      lastSharedDay: readStringOrNull(d['lastSharedDay']),
      createdAt: readDate(d['createdAt']) ?? DateTime.now(),
    );
  }
}

/// A "Cheer" a friend sent you: users/{uid}/cheers/{fromUid_day}.
class Cheer {
  const Cheer({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.createdAt,
  });

  final String id;
  final String fromUid;
  final String fromName;
  final DateTime createdAt;

  factory Cheer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Cheer(
      id: doc.id,
      fromUid: readString(d['fromUid']),
      fromName: readString(d['fromName'], 'A friend'),
      createdAt: readDate(d['createdAt']) ?? DateTime.now(),
    );
  }
}

enum FriendStatusKind { focusingNow, focusedToday, notYetToday }

/// One row of "Your study circle", ready to display.
class FriendCard {
  const FriendCard({
    required this.friendshipId,
    required this.uid,
    required this.name,
    required this.equipped,
    required this.sharedStreak,
    required this.status,
    required this.minutesToday,
    required this.focusedToday,
  });

  final String friendshipId;
  final String uid;
  final String name;
  final EquippedItems equipped;

  /// "5-day shared streak"
  final int sharedStreak;
  final FriendStatusKind status;
  final int minutesToday;
  final bool focusedToday;

  /// "Focusing now" / "75 min today" / "Not yet today"
  String get statusText => switch (status) {
        FriendStatusKind.focusingNow => 'Focusing now',
        FriendStatusKind.focusedToday => '$minutesToday min today',
        FriendStatusKind.notYetToday => 'Not yet today',
      };

  factory FriendCard.build({
    required Friendship friendship,
    required PublicProfile profile,
    required DateTime now,
  }) {
    final today = dayKey(now);
    final focusing = profile.isFocusing(now);
    final minutes = profile.minutesOn(today);
    return FriendCard(
      friendshipId: friendship.id,
      uid: profile.uid,
      name: profile.displayName,
      equipped: profile.equipped,
      sharedStreak: friendship.streakOn(today),
      status: focusing
          ? FriendStatusKind.focusingNow
          : (minutes > 0
              ? FriendStatusKind.focusedToday
              : FriendStatusKind.notYetToday),
      minutesToday: minutes,
      focusedToday: profile.focusedOn(today),
    );
  }
}

/// The green card at the top of the Friends tab:
/// "YOU + MAYA · 5 days of showing up · 1 of 2 focused today".
class FriendsHero {
  const FriendsHero({required this.friend, required this.focusedCount});

  final FriendCard friend;

  /// How many of the two (you + friend) have focused today: 0, 1 or 2.
  final int focusedCount;

  String get progressText => '$focusedCount of 2 focused today';
}
