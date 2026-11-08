import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/core/app_exception.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/core/firestore_helpers.dart';
import 'package:tutomato/core/firestore_paths.dart';
import 'package:tutomato/logic/streak.dart';
import 'package:tutomato/models/converters.dart';
import 'package:tutomato/models/friends.dart';

/// Study friends and shared streaks.
///
/// How it works:
///  - Every user has a short invite code (shown under "Invite a study friend").
///  - A friend types it in -> a `friendships/{uidA_uidB}` document is created
///    straight away (no request/accept step, to keep the first version simple).
///  - The shared streak goes up on a day when BOTH friends completed a session.
///  - Friends see each other through `publicProfiles/{uid}` only.
class FriendRepository {
  FriendRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _friendships =>
      _db.collection(FirestorePaths.friendships);

  DocumentReference<Map<String, dynamic>> _public(String uid) =>
      _db.collection(FirestorePaths.publicProfiles).doc(uid);

  CollectionReference<Map<String, dynamic>> _cheers(String uid) => _db
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.cheers);

  Stream<List<Friendship>> watchFriendships(String uid) => _friendships
      .where('members', arrayContains: uid)
      .snapshots()
      .map((snap) => snap.docs.map(Friendship.fromDoc).toList());

  Stream<PublicProfile?> watchPublicProfile(String uid) => _public(uid)
      .snapshots()
      .map((s) => s.exists ? PublicProfile.fromDoc(s) : null);

  /// "Invite a study friend": add someone by the code they shared with you.
  Future<void> addFriendByCode(String myUid, String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) throw const AppException('Enter your friend\'s invite code.');

    final match = await _db
        .collection(FirestorePaths.publicProfiles)
        .where('inviteCode', isEqualTo: clean)
        .limit(1)
        .get();
    if (match.docs.isEmpty) {
      throw const AppException('No student found with that code. Check it and try again.');
    }

    final friendUid = match.docs.first.id;
    if (friendUid == myUid) {
      throw const AppException('That\'s your own code! Share it with a friend instead.');
    }

    final pairId = FirestorePaths.pairId(myUid, friendUid);
    final ref = _friendships.doc(pairId);
    if ((await ref.get()).exists) {
      throw const AppException('You\'re already study friends.');
    }

    await ref.set({
      'members': [myUid, friendUid]..sort(),
      'sharedStreak': 0,
      'bestSharedStreak': 0,
      'lastSharedDay': null,
      'createdAt': Timestamp.now(),
    }).offlineSafe();
  }

  Future<void> removeFriend(String friendshipId) =>
      _friendships.doc(friendshipId).delete().offlineSafe();

  /// The "Cheer" button. One cheer per friend per day: sending again just
  /// overwrites today's cheer instead of spamming.
  Future<void> cheer({
    required String fromUid,
    required String fromName,
    required String toUid,
    required DateTime now,
  }) =>
      _cheers(toUid).doc('${fromUid}_${dayKey(now)}').set({
        'fromUid': fromUid,
        'fromName': fromName,
        'createdAt': Timestamp.fromDate(now),
      }).offlineSafe();

  Stream<List<Cheer>> watchCheers(String uid) => _cheers(uid)
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs.map(Cheer.fromDoc).toList());

  /// Call after the user completes a session. For every friendship where the
  /// friend has ALSO completed a session today, bump the shared streak (once
  /// per day). Whichever friend finishes second triggers the bump. Needs the
  /// network; it is best-effort and the next completed session will retry.
  Future<void> onSessionCompleted({
    required String myUid,
    required DateTime now,
  }) async {
    final today = dayKey(now);
    final mine = await _friendships.where('members', arrayContains: myUid).get();

    for (final doc in mine.docs) {
      final friendship = Friendship.fromDoc(doc);
      if (friendship.lastSharedDay == today) continue;

      final friendSnap = await _public(friendship.otherUid(myUid)).get();
      if (!friendSnap.exists) continue;
      if (!PublicProfile.fromDoc(friendSnap).focusedOn(today)) continue;

      await _db.runTransaction((tx) async {
        final fresh = await tx.get(doc.reference);
        final data = fresh.data();
        if (data == null) return;
        final next = advanceStreak(
          StreakState(
            current: readInt(data['sharedStreak']),
            best: readInt(data['bestSharedStreak']),
            lastDay: readStringOrNull(data['lastSharedDay']),
          ),
          today,
        );
        if (next.lastDay == readStringOrNull(data['lastSharedDay'])) return;
        tx.update(doc.reference, {
          'sharedStreak': next.current,
          'bestSharedStreak': next.best,
          'lastSharedDay': next.lastDay,
        });
      });
    }
  }
}
