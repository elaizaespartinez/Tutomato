import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';

void showCreateSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cream,
    constraints: const BoxConstraints(maxWidth: 600),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheet) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Make room for growth',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brown)),
          const SizedBox(height: 4),
          const Text('What would you like to do?',
              style: TextStyle(color: AppColors.brownSoft)),
          const SizedBox(height: 16),
          _Option(
            background: AppColors.peach,
            textColor: AppColors.brown,
            icon: Icons.add,
            title: 'Add a task',
            subtitle: 'Plan your next little win.',
            onTap: () {
              Navigator.pop(sheet);
              Navigator.pushNamed(context, AppRoutes.addTask);
            },
          ),
          const SizedBox(height: 12),
          _Option(
            background: AppColors.leaf,
            textColor: Colors.white,
            icon: Icons.timer_outlined,
            title: 'Start a focus session',
            subtitle: 'Pick a task and lock in.',
            onTap: () {
              Navigator.pop(sheet);
              Navigator.pushNamed(context, AppRoutes.sessionSetup);
            },
          ),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(sheet),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Option extends StatelessWidget {
  final Color background;
  final Color textColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Option({
    required this.background,
    required this.textColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text(subtitle,
                        style: TextStyle(
                            color: textColor.withValues(alpha: 0.8))),
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