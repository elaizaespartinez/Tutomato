import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A rounded filter / tab chip.
class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final bool outlined; // inactive chips have a border instead of a fill

  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor = AppColors.leaf,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final idleFill = outlined ? AppColors.card : AppColors.peach;
    final idleBorder = outlined ? AppColors.border : Colors.transparent;
    return Material(
      color: selected ? activeColor : idleFill,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? activeColor : idleBorder),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.brownSoft,
            ),
          ),
        ),
      ),
    );
  }
}
