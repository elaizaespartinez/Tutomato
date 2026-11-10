import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PageWidth extends StatelessWidget {
  final Widget child;
  const PageWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.cream,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: child,
      ),
    ),
  );
}