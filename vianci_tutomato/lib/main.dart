import 'package:flutter/material.dart';

import 'models/study_task.dart';
import 'screens/community_screens.dart';
import 'screens/onboarding_screens.dart';
import 'screens/study_screens.dart';
import 'theme.dart';
import 'widgets/app_widgets.dart';

void main() {
  runApp(const TutomatoApp());
}

enum AppPage {
  welcome,
  login,
  signup,
  home,
  learn,
  addTask,
  sessionSetup,
  focusSession,
  sessionComplete,
  wardrobe,
  records,
  friends,
  profile,
}

class TutomatoApp extends StatelessWidget {
  const TutomatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutomato',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _TutomatoHome(),
    );
  }
}

class _TutomatoHome extends StatefulWidget {
  const _TutomatoHome();

  @override
  State<_TutomatoHome> createState() => _TutomatoHomeState();
}

class _TutomatoHomeState extends State<_TutomatoHome> {
  AppPage _page = AppPage.welcome;
  final List<StudyTask> _tasks = [
    StudyTask(
      title: 'Cell division review',
      subject: 'Biology',
      dueLabel: 'Today',
      sessionsGoal: 2,
    ),
    StudyTask(
      title: 'Practice derivatives',
      subject: 'Mathematics',
      dueLabel: 'Today',
      sessionsGoal: 3,
      completedSessions: 1,
    ),
    StudyTask(
      title: 'Read Chapter 4',
      subject: 'Literature',
      dueLabel: 'Tomorrow',
      sessionsGoal: 1,
    ),
  ];

  String _name = 'Alex';
  String _email = 'alex.rivera@university.edu';
  String _activeTaskId = '';
  String _activeTaskTitle = 'Cell division review';
  String _activeTaskSubject = 'Biology';
  int _points = 240;
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _rounds = 4;
  int _completedSessions = 2;
  int _focusMinutesToday = 50;
  bool _isBreak = false;

  bool get _hasBottomNav => switch (_page) {
    AppPage.home ||
    AppPage.learn ||
    AppPage.wardrobe ||
    AppPage.records ||
    AppPage.friends ||
    AppPage.profile => true,
    _ => false,
  };

  int get _selectedTab => switch (_page) {
    AppPage.wardrobe => 1,
    AppPage.records => 3,
    AppPage.friends => 4,
    _ => 0,
  };

  void _navigate(AppPage page) {
    setState(() => _page = page);
  }

  void _openSetup() {
    final firstTask = _tasks.where((task) => !task.isDone).firstOrNull;
    if (firstTask != null) {
      _activeTaskId = firstTask.id;
      _activeTaskTitle = firstTask.title;
      _activeTaskSubject = firstTask.subject;
    }
    _navigate(AppPage.sessionSetup);
  }

  void _selectTab(int index) {
    switch (index) {
      case 0:
        _navigate(AppPage.home);
      case 1:
        _navigate(AppPage.wardrobe);
      case 2:
        _showQuickActions();
      case 3:
        _navigate(AppPage.records);
      case 4:
        _navigate(AppPage.friends);
    }
  }

  Future<void> _showQuickActions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text('Make room for growth', style: AppTextStyles.title),
              const SizedBox(height: 6),
              const Text(
                'What would you like to do?',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              _QuickActionTile(
                icon: Icons.add,
                title: 'Add a task',
                subtitle: 'Plan your next little win.',
                color: AppColors.peach,
                foreground: AppColors.red,
                onTap: () {
                  Navigator.pop(context);
                  _navigate(AppPage.addTask);
                },
              ),
              const SizedBox(height: 12),
              _QuickActionTile(
                icon: Icons.timer_outlined,
                title: 'Start a focus session',
                subtitle: 'Pick a task and lock in.',
                color: AppColors.green,
                foreground: AppColors.cream,
                onTap: () {
                  Navigator.pop(context);
                  _openSetup();
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: AppTextStyles.body),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask(StudyTask task) {
    setState(() {
      _tasks.add(task);
      _page = AppPage.learn;
    });
  }

  void _startSession(String taskId, int minutes, int breaks, int rounds) {
    final task = _tasks.where((item) => item.id == taskId).firstOrNull;
    if (task != null) {
      _activeTaskId = task.id;
      _activeTaskTitle = task.title;
      _activeTaskSubject = task.subject;
    }
    setState(() {
      _isBreak = false;
      _focusMinutes = minutes;
      _breakMinutes = breaks;
      _rounds = rounds;
      _page = AppPage.focusSession;
    });
  }

  void _startBreak() {
    setState(() {
      _isBreak = true;
      _focusMinutes = _breakMinutes;
      _page = AppPage.focusSession;
    });
  }

  void _finishSession({required bool completed}) {
    if (_isBreak) {
      setState(() {
        _isBreak = false;
        _page = AppPage.home;
      });
      return;
    }
    if (completed) {
      setState(() {
        final index = _tasks.indexWhere((task) => task.id == _activeTaskId);
        if (index >= 0) {
          _tasks[index] = _tasks[index].copyWith(
            completedSessions: _tasks[index].completedSessions + 1,
          );
        }
        _points += 25;
        _completedSessions += 1;
        _focusMinutesToday += _focusMinutes;
        _page = AppPage.sessionComplete;
      });
    } else {
      _navigate(AppPage.home);
    }
  }

  void _toggleTask(String id) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index >= 0) {
        _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
      }
    });
  }

  Widget _buildPage() {
    switch (_page) {
      case AppPage.welcome:
        return WelcomeScreen(
          onGetStarted: () => _navigate(AppPage.signup),
          onLogin: () => _navigate(AppPage.login),
        );
      case AppPage.login:
        return LoginScreen(
          onBack: () => _navigate(AppPage.welcome),
          onLogin: (email) {
            setState(() {
              _email = email;
              _name = email.split('@').first.split('.').first;
              _page = AppPage.home;
            });
          },
          onSignUp: () => _navigate(AppPage.signup),
        );
      case AppPage.signup:
        return SignUpScreen(
          onBack: () => _navigate(AppPage.welcome),
          onCreateAccount: (name, email) {
            setState(() {
              _name = name.isEmpty ? 'Alex' : name;
              _email = email;
              _page = AppPage.home;
            });
          },
          onLogin: () => _navigate(AppPage.login),
        );
      case AppPage.home:
        return HomeScreen(
          name: _name,
          points: _points,
          tasks: _tasks,
          todayMinutes: _focusMinutesToday,
          completedSessions: _completedSessions,
          onOpenProfile: () => _navigate(AppPage.profile),
          onOpenLearn: () => _navigate(AppPage.learn),
          onStartSession: _openSetup,
          onToggleTask: _toggleTask,
        );
      case AppPage.learn:
        return LearnScreen(
          tasks: _tasks,
          onBack: () => _navigate(AppPage.home),
          onAddTask: () => _navigate(AppPage.addTask),
          onToggleTask: _toggleTask,
        );
      case AppPage.addTask:
        return AddTaskScreen(
          onBack: () => _navigate(AppPage.learn),
          onSave: _saveTask,
        );
      case AppPage.sessionSetup:
        return SessionSetupScreen(
          tasks: _tasks,
          selectedTaskId: _activeTaskId,
          onBack: () => _navigate(AppPage.home),
          onStart: _startSession,
        );
      case AppPage.focusSession:
        return FocusSessionScreen(
          title: _activeTaskTitle,
          subject: _activeTaskSubject,
          durationMinutes: _focusMinutes,
          rounds: _rounds,
          onEnd: () => _finishSession(completed: false),
          onComplete: () => _finishSession(completed: true),
        );
      case AppPage.sessionComplete:
        return SessionCompleteScreen(
          taskTitle: _activeTaskTitle,
          taskIsDone:
              _tasks
                  .where((task) => task.id == _activeTaskId)
                  .firstOrNull
                  ?.isDone ??
              false,
          points: 25,
          totalPoints: _points,
          onMarkDone: () => _toggleTask(_activeTaskId),
          onStartBreak: _startBreak,
          onHome: () => _navigate(AppPage.home),
        );
      case AppPage.wardrobe:
        return WardrobeScreen(
          points: _points,
          onOpenProfile: () => _navigate(AppPage.profile),
          onPurchase: (cost) => setState(() => _points -= cost),
        );
      case AppPage.records:
        return RecordsScreen(
          points: _points,
          todayMinutes: _focusMinutesToday,
          completedSessions: _completedSessions,
          onOpenProfile: () => _navigate(AppPage.profile),
        );
      case AppPage.friends:
        return FriendsScreen(onOpenProfile: () => _navigate(AppPage.profile));
      case AppPage.profile:
        return ProfileScreen(
          name: _name,
          email: _email,
          onBack: () => _navigate(AppPage.home),
          onLogout: () => _navigate(AppPage.welcome),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(child: _buildPage()),
      bottomNavigationBar: _hasBottomNav
          ? SafeArea(
              top: false,
              child: AppBottomNavigationBar(
                selectedIndex: _selectedTab,
                onSelected: _selectTab,
              ),
            )
          : null,
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 31, color: foreground),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(color: foreground),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
