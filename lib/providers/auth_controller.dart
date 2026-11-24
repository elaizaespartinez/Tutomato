import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutomato/core/app_exception.dart';
import 'package:tutomato/core/validators.dart';
import 'package:tutomato/providers/core_providers.dart';
import 'package:tutomato/providers/timer_controller.dart';

/// Welcome / Log in / Sign up screens.
///
/// `ref.watch(authControllerProvider)` gives an AsyncValue:
///   isLoading -> show a spinner on the button
///   hasError  -> `error.toString()` is a friendly message to show
/// Each method returns true on success, so the screen can navigate.
/// You do NOT navigate on success from here: watch `authStateProvider`
/// (see AuthGate) and the app swaps to the logged-in screens by itself.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) =>
      _run(() async {
        _check(Validators.name(name));
        _check(Validators.email(email));
        _check(Validators.newPassword(password));
        _check(Validators.confirmPassword(password, confirmPassword));

        final user = await ref
            .read(authServiceProvider)
            .signUp(name: name, email: email, password: password);
        await ref
            .read(userRepositoryProvider)
            .ensureProfile(uid: user.uid, name: name, email: email);
        await ref
            .read(prefsServiceProvider)
            .saveLogin(remember: true, email: email);
      });

  Future<bool> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) =>
      _run(() async {
        _check(Validators.email(email));
        _check(Validators.existingPassword(password));

        final user = await ref
            .read(authServiceProvider)
            .signIn(email: email, password: password);
        await ref.read(userRepositoryProvider).ensureProfile(
              uid: user.uid,
              name: user.displayName ?? email.split('@').first,
              email: email,
            );
        await ref
            .read(prefsServiceProvider)
            .saveLogin(remember: rememberMe, email: email);
      });

  /// "Forgot password?"
  Future<bool> sendPasswordReset(String email) => _run(() async {
        _check(Validators.email(email));
        await ref.read(authServiceProvider).sendPasswordReset(email);
      });

  /// Profile > Password & security.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _run(() async {
        _check(Validators.existingPassword(currentPassword));
        _check(Validators.newPassword(newPassword));
        _check(Validators.confirmPassword(newPassword, confirmPassword));
        await ref.read(authServiceProvider).changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            );
      });

  /// Profile > Log out.
  Future<bool> signOut() => _run(() async {
        ref.read(timerControllerProvider.notifier).reset();
        await ref.read(authServiceProvider).signOut();
      });

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }

  void _check(String? validationError) {
    if (validationError != null) throw AppException(validationError);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
