import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutomato/core/app_exception.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/models/user_profile.dart';
import 'package:tutomato/providers/core_providers.dart';
import 'package:tutomato/providers/data_providers.dart';
import 'package:tutomato/core/async_utils.dart';

/// One place for every "do something" button, so the UI never has to deal with
/// uids or repositories:
///
///   await ref.read(actionsProvider).addTask(...);
///
/// Every method throws AppException with a user-friendly message on failure;
/// catch it and show `e.toString()` in a SnackBar/dialog.
class AppActions {
  AppActions(this._ref);

  final Ref _ref;

  String get _uid {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) throw const AppException('Please log in first.');
    return uid;
  }

  DateTime get _now => _ref.read(clockProvider)();

  // ---- To Learn ----------------------------------------------------------
  /// "Save task". Returns the new task's id.
  Future<String> addTask({
    required String title,
    required String subject,
    required int plannedSessions,
    required DateTime dueDate,
  }) =>
      _ref.read(taskRepositoryProvider).addTask(
            _uid,
            title: title,
            subject: subject,
            plannedSessions: plannedSessions,
            dueDate: dueDate,
          );

  Future<void> updateTask(
    String taskId, {
    required String title,
    required String subject,
    required int plannedSessions,
    required DateTime dueDate,
  }) =>
      _ref.read(taskRepositoryProvider).updateTask(
            _uid,
            taskId,
            title: title,
            subject: subject,
            plannedSessions: plannedSessions,
            dueDate: dueDate,
          );

  /// The circle/checkbox next to a task.
  Future<void> setTaskDone(String taskId, bool done) =>
      _ref.read(taskRepositoryProvider).setDone(_uid, taskId, done);

  Future<void> deleteTask(String taskId) =>
      _ref.read(taskRepositoryProvider).deleteTask(_uid, taskId);

  // ---- Profile -----------------------------------------------------------
  /// Profile > Personal information.
  Future<void> updateName(String name) async {
    await _ref.read(userRepositoryProvider).updateName(_uid, name);
    await _ref.read(authServiceProvider).updateDisplayName(name);
  }

  /// Profile > Timer preferences, Daily focus goal, Sound & reminders.
  /// Pass the current settings changed with `copyWith`:
  ///   actions.updateSettings(profile.settings.copyWith(dailyGoalSessions: 5))
  Future<void> updateSettings(TimerSettings settings) =>
      _ref.read(userRepositoryProvider).updateSettings(_uid, settings);

  // ---- Pomodori shop -----------------------------------------------------
  /// "Buy · 80 pts"
  Future<void> buyItem(String itemId) =>
      _ref.read(shopRepositoryProvider).buy(_uid, itemId);

  /// Tap an owned item.
  Future<void> equipItem(String itemId) =>
      _ref.read(shopRepositoryProvider).equip(_uid, itemId);

  Future<void> buyAndEquipItem(String itemId) =>
      _ref.read(shopRepositoryProvider).buyAndEquip(_uid, itemId);

  // ---- Friends -----------------------------------------------------------
  /// "Invite a study friend": enter the code your friend shared.
  /// Your own code to share is `profile.inviteCode`.
  Future<void> addFriendByCode(String code) =>
      _ref.read(friendRepositoryProvider).addFriendByCode(_uid, code);

  Future<void> removeFriend(String friendshipId) =>
      _ref.read(friendRepositoryProvider).removeFriend(friendshipId);

  /// The "Cheer" button on a friend card.
  Future<void> cheer(String friendUid) {
    final profile = _ref.read(userProfileProvider).dataOrNull;
    return _ref.read(friendRepositoryProvider).cheer(
          fromUid: _uid,
          fromName: profile?.displayName ?? 'A friend',
          toUid: friendUid,
          now: _now,
        );
  }

  // ---- Helpers for screens -----------------------------------------------
  /// "yyyy-MM-dd" for today, handy for comparing with task due days.
  String get todayKey => dayKey(_now);
}

final actionsProvider = Provider<AppActions>((ref) => AppActions(ref));
