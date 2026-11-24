import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum AppButtonKind { filled, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final AppButtonKind kind;
  final IconData? icon;

  const AppButton(
      this.label, {
        super.key,
        required this.onPressed,
        this.color = AppColors.tomato,
        this.kind = AppButtonKind.filled,
        this.icon,
      });

  @override
  Widget build(BuildContext context) {
    final bigText = GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    switch (kind) {
      case AppButtonKind.filled:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: bigText,
            ),
            child: content,
          ),
        );
      case AppButtonKind.outlined:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: bigText,
              shape: const StadiumBorder(),
            ),
            child: content,
          ),
        );
      case AppButtonKind.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color,
            textStyle: GoogleFonts.fredoka(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: content,
        );
    }
  }
}