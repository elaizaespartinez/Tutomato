import 'package:shared_preferences/shared_preferences.dart';

/// Small on-device settings: the "Remember me" checkbox on the Log in screen.
class PrefsService {
  PrefsService(this._prefs);

  final SharedPreferences _prefs;

  static const rememberMeKey = 'rememberMe';
  static const rememberedEmailKey = 'rememberedEmail';

  /// Defaults to true so a user who never touched the checkbox stays logged in.
  bool get rememberMe => _prefs.getBool(rememberMeKey) ?? true;

  /// Pre-fills the email field on the Log in screen.
  String? get rememberedEmail => _prefs.getString(rememberedEmailKey);

  Future<void> saveLogin({required bool remember, required String email}) async {
    await _prefs.setBool(rememberMeKey, remember);
    if (remember) {
      await _prefs.setString(rememberedEmailKey, email.trim());
    } else {
      await _prefs.remove(rememberedEmailKey);
    }
  }
}
