import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/core/app_exception.dart';
import 'package:tutomato/core/firestore_helpers.dart';
import 'package:tutomato/core/firestore_paths.dart';
import 'package:tutomato/models/shop_item.dart';
import 'package:tutomato/models/user_profile.dart';

/// Spending Study Points and dressing the Pomodori.
/// Ownership lives on the user document (`ownedItemIds`); the catalog is in
/// code (see ShopCatalog).
class ShopRepository {
  ShopRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid);

  DocumentReference<Map<String, dynamic>> _public(String uid) =>
      _db.collection(FirestorePaths.publicProfiles).doc(uid);

  Future<UserProfile> _profile(String uid) async {
    final snap = await _user(uid).get();
    if (!snap.exists) throw const AppException('Profile not found. Please log in again.');
    return UserProfile.fromDoc(snap);
  }

  ShopItem _item(String itemId) =>
      ShopCatalog.byId(itemId) ?? (throw const AppException('That item doesn\'t exist.'));

  /// "Buy · 80 pts": spends the points and adds the item to the wardrobe.
  /// It does not equip it; call [equip] next (or [buyAndEquip]).
  Future<void> buy(String uid, String itemId) async {
    final item = _item(itemId);
    final p = await _profile(uid);
    if (p.owns(item.id)) throw const AppException('You already own this.');
    if (p.points < item.cost) {
      throw AppException(
        'You need ${item.cost - p.points} more Study Points. Finish a focus session to earn more!',
      );
    }
    await _user(uid).update({
      'points': FieldValue.increment(-item.cost),
      'ownedItemIds': FieldValue.arrayUnion([item.id]),
    }).offlineSafe();
  }

  /// Tap an owned item. One item per category stays equipped
  /// (an outfit, a color and an extra can be worn together).
  Future<void> equip(String uid, String itemId) async {
    final item = _item(itemId);
    final p = await _profile(uid);
    if (!p.owns(item.id)) throw const AppException('Buy this item first.');
    final equipped = p.equipped.withItem(item).toMap();
    final batch = _db.batch();
    batch.update(_user(uid), {'equipped': equipped});
    batch.set(_public(uid), {'equipped': equipped}, SetOptions(merge: true));
    await batch.commit().offlineSafe();
  }

  Future<void> buyAndEquip(String uid, String itemId) async {
    await buy(uid, itemId);
    await equip(uid, itemId);
  }
}
