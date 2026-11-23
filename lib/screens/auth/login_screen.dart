import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_exception.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_fields.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/pomodori_image.dart';
import '../../providers/auth_controller.dart';
import '../../providers/core_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prefsServiceProvider);
    _email.text = prefs.rememberedEmail ?? '';
    _remember = prefs.rememberMe;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text;
    setState(() {
      _emailError = email.contains('@') && email.contains('.')
          ? null
          : 'Enter a valid email address.';
      _passwordError = password.isEmpty ? 'Enter your password.' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(email: email, password: password, rememberMe: _remember);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.tomato),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log in: $e'), backgroundColor: AppColors.tomato),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address first.'),
          backgroundColor: AppColors.tomato,
        ),
      );
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email!'),
            backgroundColor: AppColors.leaf,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.tomato),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      titleWidget: const BrandHeader(),
      children: [
        const Center(child: PomodoriImage(size: 120)),
        const SizedBox(height: 12),
        Text(
          'Welcome back!',
          textAlign: TextAlign.center,
          style: AppText.h1.copyWith(fontSize: 38),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your Pomodori missed you. Ready to focus?',
          textAlign: TextAlign.center,
          style: AppText.body,
        ),
        const SizedBox(height: 28),
        AppTextField(
          label: 'Email address',
          hint: 'you@university.edu',
          icon: Icons.mail_outline,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          error: _emailError,
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline,
          password: true,
          controller: _password,
          error: _passwordError,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _remember,
              activeColor: AppColors.tomato,
              side: const BorderSide(color: AppColors.brownSoft, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: (v) => setState(() => _remember = v ?? false),
            ),
            const Text('Remember me', style: AppText.body),
            const Spacer(),
            AppButton(
              'Forgot password?',
              kind: AppButtonKind.text,
              onPressed: _forgotPassword,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.tomato))
            : AppButton('Log in', color: AppColors.leaf, onPressed: _login),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('New here?', style: AppText.body),
            AppButton(
              'Sign up',
              kind: AppButtonKind.text,
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.signup),
            ),
          ],
        ),
        const FooterNote('A little focus. A fresh start.'),
      ],
    );
  }
}