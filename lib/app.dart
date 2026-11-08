import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutomato/features/playground/playground_screens.dart';
import 'package:tutomato/providers/core_providers.dart';

class TutomatoApp extends StatelessWidget {
  const TutomatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutomato',
      debugShowCheckedModeBanner: false,
      // Placeholder theme. The real design (cream background, tomato red,
      // leaf green) comes with the UI.
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE03E2D),
        scaffoldBackgroundColor: const Color(0xFFFFF1E3),
      ),
      home: const AuthGate(),
    );
  }
}

/// Logged out -> auth screen. Logged in -> home. When the UI team builds the
/// real screens, replace the two placeholder screens below and keep this gate.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (user) =>
          user == null ? const AuthPlaceholderScreen() : const HomePlaceholderScreen(),
    );
  }
}
