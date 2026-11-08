import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/core/app_exception.dart';
import 'package:tutomato/core/constants.dart';
import 'package:tutomato/core/firestore_helpers.dart';
import 'package:tutomato/core/firestore_paths.dart';
import 'package:tutomato/models/shop_item.dart';
import 'package:tutomato/models/user_profile.dart';

/// users/{uid} (private) and publicProfiles/{uid} (what friends can see).
class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid);

  DocumentReference<Map<String, dynamic>> _public(String uid) =>
      _db.collection(FirestorePaths.publicProfiles).doc(uid);

  /// Live profile. Emits null if the document doesn't exist (yet).
  Stream<UserProfile?> watchProfile(String uid) => _user(uid)
      .snapshots()
      .map((s) => s.exists ? UserProfile.fromDoc(s) : null);

  Future<UserProfile?> getProfile(String uid) async {
    final s = await _user(uid).get();
    return s.exists ? UserProfile.fromDoc(s) : null;
  }

  /// Creates the profile on first sign-up/log-in. Safe to call every time:
  /// it does nothing when the profile already exists. (Calling it on log-in as
  /// well as sign-up repairs accounts whose profile write failed mid-way.)
  Future<void> ensureProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final existing = await _user(uid).get();
    if (existing.exists) return;

    final code = await _generateUniqueInviteCode();
    final now = Timestamp.now();
    final batch = _db.batch();
    batch.set(_user(uid), {
      'displayName': name.trim(),
      'email': email.trim(),
      'createdAt': now,
      'points': 0,
      'level': 1,
      'ripeness': 0,
      'currentStreak': 0,
      'bestStreak': 0,
      'lastActiveDay': null,
      'todayDay': null,
      'todayMinutes': 0,
      'todaySessions': 0,
      'totalSessions': 0,
      'totalFocusMinutes': 0,
      'equipped': const EquippedItems().toMap(),
      'ownedItemIds': ShopCatalog.defaultOwnedIds,
      'settings': const TimerSettings().toMap(),
      'inviteCode': code,
    });
    batch.set(_public(uid), {
      'displayName': name.trim(),
      'equipped': const EquippedItems().toMap(),
      'level': 1,
      'lastActiveDay': null,
      'todayDay': null,
      'todayMinutes': 0,
      'focusingUntil': null,
      'inviteCode': code,
      'createdAt': now,
    });
    await batch.commit().offlineSafe();
  }

  /// Profile > Personal information.
  Future<void> updateName(String uid, String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw const AppException('Please enter your name.');
    final batch = _db.batch();
    batch.update(_user(uid), {'displayName': clean});
    batch.set(_public(uid), {'displayName': clean}, SetOptions(merge: true));
    await batch.commit().offlineSafe();
  }

  /// Profile > Timer preferences / Daily focus goal / Sound & reminders.
  Future<void> updateSettings(String uid, TimerSettings settings) =>
      _user(uid).update({'settings': settings.toMap()}).offlineSafe();

  Future<String> _generateUniqueInviteCode() async {
    final rng = Random.secure();
    for (var attempt = 0; attempt < 8; attempt++) {
      final code = List.generate(
        AppConstants.inviteCodeLength,
        (_) => AppConstants.inviteCodeAlphabet[
            rng.nextInt(AppConstants.inviteCodeAlphabet.length)],
      ).join();
      final clash = await _db
          .collection(FirestorePaths.publicProfiles)
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();
      if (clash.docs.isEmpty) return code;
    }
    throw const AppException('Could not create your invite code. Try again.');
  }
}
