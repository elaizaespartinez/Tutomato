import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutomato/core/async_utils.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/logic/records.dart';
import 'package:tutomato/logic/shop_view.dart';
import 'package:tutomato/logic/task_groups.dart';
import 'package:tutomato/models/friends.dart';
import 'package:tutomato/models/shop_item.dart';
import 'package:tutomato/models/study_session.dart';
import 'package:tutomato/models/study_task.dart';
import 'package:tutomato/models/user_profile.dart';
import 'package:tutomato/providers/core_providers.dart';

// All of these are read-only views of Firestore. The UI just `ref.watch`es
// them; they update live, and they work offline from the local cache.

// ---- Profile ----------------------------------------------------------------

/// Name, points, level/ripeness, streaks, today's totals, equipped items,
/// settings. Drives Home, Pomodori, Profile.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchProfile(uid);
});

// ---- To Learn ---------------------------------------------------------------

final tasksProvider = StreamProvider<List<StudyTask>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const <StudyTask>[]);
  return ref.watch(taskRepositoryProvider).watchTasks(uid);
});

/// Chips + sections of the To Learn screen (todo / today / upcoming / done).
final taskGroupsProvider = Provider<TaskGroups>((ref) {
  final tasks = ref.watch(tasksProvider).dataOrNull;
  if (tasks == null) return TaskGroups.empty;
  final today = dayKey(ref.watch(clockProvider)());
  return TaskGroups.from(tasks, today);
});

// ---- Records ----------------------------------------------------------------

/// The week the Records screen is showing (Monday). Change it to browse weeks.
final selectedWeekProvider =
    StateProvider<DateTime>((ref) => startOfWeek(DateTime.now()));

final weekSessionsProvider =
    StreamProvider.family<List<StudySession>, DateTime>((ref, weekStart) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const <StudySession>[]);
  return ref
      .watch(sessionRepositoryProvider)
      .watchSessionsBetween(uid, weekStart, addDays(weekStart, 7));
});

/// Focus time, sessions completed, the 7 bars and today's sessions for the
/// given Monday. Null while loading.
final weeklyStatsProvider = Provider.family<WeeklyStats?, DateTime>((ref, weekStart) {
  final sessions = ref.watch(weekSessionsProvider(weekStart)).dataOrNull;
  if (sessions == null) return null;
  return buildWeeklyStats(
    sessions,
    weekStart: weekStart,
    today: ref.watch(clockProvider)(),
  );
});

// ---- Pomodori shop ----------------------------------------------------------

/// Cards for one tab (outfit / color / extra) of the Pomodori screen.
final shopEntriesProvider =
    Provider.family<List<ShopEntry>, ShopCategory>((ref, category) {
  final profile = ref.watch(userProfileProvider).dataOrNull;
  if (profile == null) return const <ShopEntry>[];
  return buildShopEntries(profile, category);
});

// ---- Friends ----------------------------------------------------------------

final friendshipsProvider = StreamProvider<List<Friendship>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const <Friendship>[]);
  return ref.watch(friendRepositoryProvider).watchFriendships(uid);
});

final publicProfileProvider =
    StreamProvider.family<PublicProfile?, String>((ref, uid) {
  return ref.watch(friendRepositoryProvider).watchPublicProfile(uid);
});

/// "Your study circle": one card per friend, longest shared streak first.
final friendCardsProvider = Provider<List<FriendCard>>((ref) {
  final me = ref.watch(currentUidProvider);
  final friendships = ref.watch(friendshipsProvider).dataOrNull;
  if (me == null || friendships == null) return const <FriendCard>[];
  final now = ref.watch(clockProvider)();

  final cards = <FriendCard>[];
  for (final friendship in friendships) {
    final profile =
        ref.watch(publicProfileProvider(friendship.otherUid(me))).dataOrNull;
    if (profile == null) continue;
    cards.add(FriendCard.build(friendship: friendship, profile: profile, now: now));
  }
  cards.sort((a, b) => b.sharedStreak.compareTo(a.sharedStreak));
  return cards;
});

/// The green "YOU + MAYA" card: the friend with the longest shared streak.
/// Null when there are no friends yet (show the invite prompt instead).
final friendsHeroProvider = Provider<FriendsHero?>((ref) {
  final cards = ref.watch(friendCardsProvider);
  if (cards.isEmpty) return null;
  final profile = ref.watch(userProfileProvider).dataOrNull;
  final today = dayKey(ref.watch(clockProvider)());
  final meFocused = profile?.focusedOn(today) ?? false;
  final friend = cards.first;
  return FriendsHero(
    friend: friend,
    focusedCount: (meFocused ? 1 : 0) + (friend.focusedToday ? 1 : 0),
  );
});

/// Cheers received from friends (newest first).
final cheersProvider = StreamProvider<List<Cheer>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const <Cheer>[]);
  return ref.watch(friendRepositoryProvider).watchCheers(uid);
});
