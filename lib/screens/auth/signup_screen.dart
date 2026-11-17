import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_fields.dart';
import '../../core/widgets/app_page.dart';
import '../../providers/app_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _create() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _password.text;
    final goodPassword =
        pass.length >= 8 &&
            RegExp(r'[A-Za-z]').hasMatch(pass) &&
            RegExp(r'\d').hasMatch(pass);

    setState(() {
      _nameError = name.isEmpty ? 'Tell us what to call you.' : null;
      _emailError = email.contains('@') && email.contains('.')
          ? null
          : 'Enter a valid email address.';
      _passwordError = goodPassword
          ? null
          : 'Use at least 8 characters, a letter, and a number.';
      _confirmError = _confirm.text == pass
          ? null
          : 'The passwords don’t match.';
    });
    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    // TODO: create the account in your online database.
    final app = AppState.instance;
    app.update(() {
      app.fullName = name;
      app.userName = name.split(' ').first;
      app.email = email;
    });
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
        Text('Let’s grow together.', style: AppText.h1.copyWith(fontSize: 38)),
        const SizedBox(height: 8),
        const Text(
          'Create your account and start ripening up.',
          style: AppText.body,
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Your name',
          hint: 'Your name',
          icon: Icons.person_outline,
          controller: _name,
          error: _nameError,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Email address',
          hint: 'you@university.edu',
          icon: Icons.mail_outline,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          error: _emailError,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Password',
          hint: 'Create a password',
          icon: Icons.lock_outline,
          password: true,
          controller: _password,
          error: _passwordError,
          helper: _passwordError == null
              ? 'Use at least 8 characters, a letter, and a number.'
              : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Confirm password',
          hint: 'Re-enter your password',
          icon: Icons.lock_outline,
          password: true,
          controller: _confirm,
          error: _confirmError,
        ),
        const SizedBox(height: 20),
        const Text.rich(
          TextSpan(
            style: AppText.small,
            children: [
              TextSpan(text: 'By creating an account, you agree to our '),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(color: AppColors.tomato),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(color: AppColors.tomato),
              ),
              TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        AppButton('Create account', color: AppColors.leaf, onPressed: _create),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account?', style: AppText.body),
            AppButton(
              'Log in',
              kind: AppButtonKind.text,
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
            ),
          ],
        ),
      ],
    );
  }
}
