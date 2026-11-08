import 'package:flutter/widgets.dart';

/// Lock-in mode. While a focus session runs, [onLeftApp] fires the moment the
/// app goes to the background (home button, switching apps, locking the
/// screen, an incoming call, the recents screen).
///
/// Limits, as stated in the project scope: this detects *leaving the app*, not
/// whether the user is really studying, and it does not block other apps.
///
/// We react to `paused` only. `inactive` also fires for harmless things such as
/// pulling down the notification shade or a system permission dialog, so using
/// it would break sessions unfairly.
class LockInService with WidgetsBindingObserver {
  VoidCallback? _onLeftApp;
  bool _active = false;

  bool get isActive => _active;

  void start(VoidCallback onLeftApp) {
    stop();
    _onLeftApp = onLeftApp;
    _active = true;
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    if (!_active) return;
    WidgetsBinding.instance.removeObserver(this);
    _active = false;
    _onLeftApp = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_active && state == AppLifecycleState.paused) {
      final callback = _onLeftApp;
      stop(); // fire once
      callback?.call();
    }
  }
}
