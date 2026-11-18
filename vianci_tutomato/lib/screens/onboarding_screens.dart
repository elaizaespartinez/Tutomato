import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/app_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onGetStarted,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Tutomato',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.red,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 30),
          const TomatoMascot(size: 250),
          const SizedBox(height: 18),
          Text(
            'Lock in to ripen up!',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 14),
          Text(
            'Focus with the Pomodoro timer, earn Study Points, and help Pomodori grow.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 26),
          const Row(
            children: [
              _WelcomePill(icon: Icons.timer_outlined, label: 'Time it'),
              SizedBox(width: 8),
              _WelcomePill(icon: Icons.menu_book_outlined, label: 'Focus'),
              SizedBox(width: 8),
              _WelcomePill(icon: Icons.star_outline, label: 'Rewards'),
            ],
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Get started',
            color: AppColors.green,
            height: 62,
            onPressed: onGetStarted,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onLogin,
            child: Text(
              'I already have an account',
              style: AppTextStyles.body.copyWith(
                color: AppColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePill extends StatelessWidget {
  const _WelcomePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        decoration: BoxDecoration(
          color: AppColors.peach,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.red),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onBack,
    required this.onLogin,
    required this.onSignUp,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onLogin;
  final VoidCallback onSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: 'alex.rivera@university.edu',
  );
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: AppColors.brown,
                ),
                const Spacer(),
                Text(
                  'Tutomato',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.red,
                    fontSize: 26,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 22),
            const Center(child: TomatoMascot(size: 112)),
            const SizedBox(height: 10),
            const Text('Welcome back!', style: AppTextStyles.heading),
            const SizedBox(height: 4),
            const Text(
              'Your Pomodori missed you. Ready to focus?',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 26),
            const _FieldLabel('Email address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail_outline, size: 20),
                hintText: 'you@university.edu',
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 18),
            const _FieldLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, size: 20),
                hintText: 'Your password',
              ),
              validator: (value) => (value == null || value.length < 4)
                  ? 'Enter your password'
                  : null,
            ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.green,
                      visualDensity: VisualDensity.compact,
                      onChanged: (value) =>
                          setState(() => _rememberMe = value ?? false),
                    ),
                    const Text(
                      'Remember me',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset is available soon.'),
                    ),
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: AppColors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Log in',
              color: AppColors.green,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('New here? ', style: AppTextStyles.body),
                  TextButton(
                    onPressed: widget.onSignUp,
                    child: const Text(
                      'Sign up',
                      style: TextStyle(color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'A little focus. A fresh start.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    required this.onBack,
    required this.onCreateAccount,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onBack;
  final void Function(String name, String email) onCreateAccount;
  final VoidCallback onLogin;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onCreateAccount(
        _nameController.text.trim(),
        _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: AppColors.brown,
                ),
                const Spacer(),
                Text(
                  'Tutomato',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.red,
                    fontSize: 25,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Let’s grow together.', style: AppTextStyles.heading),
            const SizedBox(height: 5),
            const Text(
              'Create your account and start ripening up.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 22),
            const _FieldLabel('Your name'),
            const SizedBox(height: 7),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline, size: 20),
                hintText: 'Your name',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter your name'
                  : null,
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Email address'),
            const SizedBox(height: 7),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail_outline, size: 20),
                hintText: 'you@university.edu',
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Password'),
            const SizedBox(height: 7),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                hintText: 'Create a password',
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) => (value == null || value.length < 6)
                  ? 'Use at least 6 characters'
                  : null,
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Confirm password'),
            const SizedBox(height: 7),
            TextFormField(
              controller: _confirmController,
              obscureText: !_showPassword,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, size: 20),
                hintText: 'Re-enter your password',
              ),
              validator: (value) => value != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 10),
            const Text(
              'Use at least 6 characters, a letter, and a number.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Create account',
              color: AppColors.green,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: AppTextStyles.body,
                  ),
                  TextButton(
                    onPressed: widget.onLogin,
                    child: const Text(
                      'Log in',
                      style: TextStyle(color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.brown,
        fontSize: 14,
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (!email.contains('@') || !email.contains('.')) {
    return 'Enter a valid email address';
  }
  return null;
}
