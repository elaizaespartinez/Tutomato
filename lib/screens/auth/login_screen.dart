import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_fields.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/pomodori_image.dart';
import '../../providers/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    final email = _email.text.trim();
    setState(() {
      _emailError = email.contains('@') && email.contains('.')
          ? null
          : 'Enter a valid email address.';
      _passwordError = _password.text.isEmpty ? 'Enter your password.' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    // TODO: check the email and password against your online database.
    AppState.instance.update(() => AppState.instance.email = email);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.shell,
          (route) => false,
    );
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
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Password reset will work once accounts are connected.',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppButton('Log in', color: AppColors.leaf, onPressed: _login),
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
