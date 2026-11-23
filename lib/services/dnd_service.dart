import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Turns the phone's Do Not Disturb on and off. Android only; every call
/// quietly does nothing on other platforms.
class DndService {
  DndService._();
  static final DndService instance = DndService._();

  static const _channel = MethodChannel('tutomato/dnd');

  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> hasAccess() => _call('hasAccess');
  Future<bool> enable() => _call('enable');
  Future<void> disable() => _call('disable');

  Future<void> openSettings() async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>('openSettings');
    } catch (e) {
      debugPrint('DND settings error: $e');
    }
  }

  Future<bool> _call(String method) async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } catch (e) {
      debugPrint('DND $method error: $e');
      return false;
    }
  }
}