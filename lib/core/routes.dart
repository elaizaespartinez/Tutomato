import 'package:flutter/material.dart';
import '../screens/shell/main_shell.dart';
import 'widgets/placeholder_screen.dart';

class AppRoutes {
  static const shell = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const toLearn = '/to-learn';
  static const addTask = '/add-task';
  static const sessionSetup = '/session-setup';
  static const focus = '/focus';
  static const complete = '/complete';
  static const breakTime = '/break';
  static const lockBroken = '/lock-broken';
  static const profile = '/profile';

  static Map<String, WidgetBuilder> get table => {
    shell: (_) => const MainShell(),
    welcome: (_) => const PlaceholderScreen('Welcome'),
    login: (_) => const PlaceholderScreen('Welcome back!'),
    signup: (_) => const PlaceholderScreen("Let's grow together."),
    toLearn: (_) => const PlaceholderScreen('To Learn'),
    addTask: (_) => const PlaceholderScreen('Add a task'),
    sessionSetup: (_) => const PlaceholderScreen('Start a session'),
    focus: (_) => const PlaceholderScreen('Focus session'),
    complete: (_) => const PlaceholderScreen('Session complete!'),
    breakTime: (_) => const PlaceholderScreen('A little breather'),
    lockBroken: (_) => const PlaceholderScreen('Lock-in broken'),
    profile: (_) => const PlaceholderScreen('Your profile'),
  };
}