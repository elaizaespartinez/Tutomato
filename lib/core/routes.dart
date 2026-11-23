import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/session/session_screen.dart';
import '../screens/session/session_setup_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/tasks/add_task_screen.dart';
import '../screens/tasks/to_learn_screen.dart';

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
    welcome: (_) => const WelcomeScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    toLearn: (_) => const ToLearnScreen(),
    addTask: (_) => const AddTaskScreen(),
    sessionSetup: (_) => const SessionSetupScreen(),
    // Focus, complete, break and lock-broken are one screen that switches
    // view by itself, so all four names open the same widget.
    focus: (_) => const SessionScreen(),
    complete: (_) => const SessionScreen(),
    breakTime: (_) => const SessionScreen(),
    lockBroken: (_) => const SessionScreen(),
    profile: (_) => const ProfileScreen(),
  };
}