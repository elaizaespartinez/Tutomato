import 'dart:async';

import 'package:flutter/foundation.dart';

/// Firestore write futures only complete once the *server* acknowledges the
/// write. Offline, they would hang forever even though the write is safely
/// queued locally and will sync later. `offlineSafe` stops waiting after a few
/// seconds so the UI never freezes when the phone has no signal.
extension OfflineSafeWrite on Future<void> {
  Future<void> offlineSafe({Duration wait = const Duration(seconds: 3)}) async {
    try {
      await timeout(wait);
    } on TimeoutException {
      debugPrint('Write queued offline; it will sync when back online.');
    }
  }
}

/// Fire a write without awaiting it (used where the UI must react instantly,
/// e.g. the moment a focus session starts or the lock-in breaks).
void runInBackground(Future<void> write, String label) {
  unawaited(write.catchError((Object e) {
    debugPrint('Background write failed ($label): $e');
  }));
}
