import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/pomodori_image.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      showBack: false,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tutomato',
            style: AppText.brandStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.tomato,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Center(child: PomodoriImage(size: 230)),
        const SizedBox(height: 16),
        Text(
          'Lock in to ripen up!',
          textAlign: TextAlign.center,
          style: AppText.h1.copyWith(fontSize: 38),
        ),
        const SizedBox(height: 12),
        Text(
          'Focus with the Pomodoro timer, earn Study Points, and help Pomodori grow.',
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 24),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _Feature(Icons.timer_outlined, 'Time it', AppColors.tomato),
            _Feature(Icons.menu_book_outlined, 'Focus', AppColors.leaf),
            _Feature(Icons.star_border, 'Rewards', AppColors.tomato),
          ],
        ),
        const SizedBox(height: 28),
        AppButton(
          'Get started',
          color: AppColors.leaf,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
        ),
        const SizedBox(height: 8),
        Center(
          child: AppButton(
            'I already have an account',
            kind: AppButtonKind.text,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          ),
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Feature(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.peach,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(label, style: AppText.title),
      ],
    ),
  );
}