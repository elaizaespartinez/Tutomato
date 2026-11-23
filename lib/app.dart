import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/core_providers.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/shell/main_shell.dart';

class TutomatoApp extends StatelessWidget {
  const TutomatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutomato',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: AppRoutes.table,
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator(color: AppColors.tomato)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
          return KeyedSubtree(
            key: ValueKey('main_shell_${user.uid}'),
            child: const MainShell(),
          );
        }
        return const KeyedSubtree(
          key: ValueKey('welcome_screen'),
          child: WelcomeScreen(),
        );
      },
    );
  }
}