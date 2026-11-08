import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutomato/providers/core_providers.dart';

/// Run once after login. If the app was killed during a focus session (swiped
/// away, crashed, battery died), that session is still marked "in progress";
/// this marks it broken, because the user did leave the app.
///
/// `ref.watch(staleSessionCleanupProvider)` once from the logged-in root screen.
final staleSessionCleanupProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return;
  final startedBefore = ref.read(clockProvider)();
  try {
    await ref
        .read(sessionRepositoryProvider)
        .failStaleSessions(uid, startedBefore: startedBefore);
  } catch (_) {
    // Best-effort cleanup; never block the app on it.
  }
});
