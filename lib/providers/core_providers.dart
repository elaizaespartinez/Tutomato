import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutomato/core/async_utils.dart';
import 'package:tutomato/repositories/friend_repository.dart';
import 'package:tutomato/repositories/session_repository.dart';
import 'package:tutomato/repositories/shop_repository.dart';
import 'package:tutomato/repositories/task_repository.dart';
import 'package:tutomato/repositories/user_repository.dart';
import 'package:tutomato/services/auth_service.dart';
import 'package:tutomato/services/prefs_service.dart';

// ---- Firebase + device ------------------------------------------------------

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// Overridden in main() with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

/// The current time. Tests can override this to fake the clock.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

// ---- Services & repositories ------------------------------------------------

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.watch(firebaseAuthProvider)));

final prefsServiceProvider =
    Provider<PrefsService>((ref) => PrefsService(ref.watch(sharedPreferencesProvider)));

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository(ref.watch(firestoreProvider)));

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository(ref.watch(firestoreProvider)));

final sessionRepositoryProvider = Provider<SessionRepository>(
    (ref) => SessionRepository(ref.watch(firestoreProvider)));

final shopRepositoryProvider =
    Provider<ShopRepository>((ref) => ShopRepository(ref.watch(firestoreProvider)));

final friendRepositoryProvider = Provider<FriendRepository>(
    (ref) => FriendRepository(ref.watch(firestoreProvider)));

// ---- Who is logged in -------------------------------------------------------

/// Emits the Firebase user, or null when logged out.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);

/// The signed-in user's uid, or null. Everything user-specific watches this, so
/// logging out/in automatically swaps all the data.
final currentUidProvider =
    Provider<String?>((ref) => ref.watch(authStateProvider).dataOrNull?.uid);
