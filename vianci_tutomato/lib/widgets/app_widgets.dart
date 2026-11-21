import 'package:flutter/material.dart';

import '../theme.dart';
export 'tomato_mascot.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.card,
    this.borderColor = AppColors.border,
    this.radius = 22,
    this.borderWidth = 1.4,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.color = AppColors.red,
    this.textColor = AppColors.white,
    this.height = 54,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        child: icon == null
            ? Text(label)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(icon), const SizedBox(width: 8), Text(label)],
              ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  const OutlineButton({
    required this.label,
    required this.onPressed,
    this.height = 52,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: const BorderSide(color: AppColors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle({
    required this.title,
    this.onBack,
    this.trailing,
    this.size = 27,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.brown,
              size: 23,
            ),
          ),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.heading.copyWith(fontSize: size),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.heading.copyWith(fontSize: 23),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({this.onProfile, super.key});

  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Tutomato',
          style: AppTextStyles.heading.copyWith(
            fontSize: 27,
            color: AppColors.red,
            letterSpacing: -.4,
          ),
        ),
        const Spacer(),
        if (onProfile != null)
          IconButton.filledTonal(
            onPressed: onProfile,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.peach,
              foregroundColor: AppColors.brown,
              fixedSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.person_outline),
          ),
      ],
    );
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.spa_outlined, 'Pomodori'),
    (Icons.add, 'Add'),
    (Icons.bar_chart_rounded, 'Records'),
    (Icons.people_alt_outlined, 'Friends'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.cream,
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = selectedIndex == index;
          if (index == 2) {
            return Expanded(
              child: Center(
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: FilledButton(
                    onPressed: () => onSelected(index),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 32),
                  ),
                ),
              ),
            );
          }
          return Expanded(
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.peach : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      item.$1,
                      color: selected ? AppColors.red : AppColors.muted,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.red : AppColors.muted,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


