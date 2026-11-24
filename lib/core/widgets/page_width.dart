import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PageWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const PageWidth({super.key, required this.child, this.maxWidth = 600});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.cream,
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    ),
  );
}