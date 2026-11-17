import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_card.dart';

/// A round − or + button. Pass null to disable it.
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const RoundIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.35 : 1,
      child: Material(
        color: AppColors.peach,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: AppColors.tomato, size: 22),
          ),
        ),
      ),
    );
  }
}

/// The wide "− 2 sessions +" bar on the Add a task screen.
class StepperBar extends StatelessWidget {
  final String label;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const StepperBar({
    super.key,
    required this.label,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.peach,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: onMinus,
              icon: const Icon(Icons.remove),
              color: AppColors.tomato,
              iconSize: 28,
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppText.h2.copyWith(fontSize: 22),
              ),
            ),
            IconButton(
              onPressed: onPlus,
              icon: const Icon(Icons.add),
              color: AppColors.tomato,
              iconSize: 28,
            ),
          ],
        ),
      ),
    );
  }
}

/// A small card with a title and round − / + buttons (Focus, Short break, Rounds).
class StepperCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const StepperCard({
    super.key,
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.small.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              RoundIconButton(icon: Icons.remove, onTap: onMinus),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: AppText.h2.copyWith(fontSize: 22)),
                ),
              ),
              RoundIconButton(icon: Icons.add, onTap: onPlus),
            ],
          ),
        ],
      ),
    );
  }
}
