import 'package:flutter/material.dart';

import '../theme.dart';

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

class TomatoMascot extends StatelessWidget {
  const TomatoMascot({this.size = 160, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * .96,
      child: CustomPaint(painter: _TomatoPainter()),
    );
  }
}

class _TomatoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 192);

    final red = Paint()..color = const Color(0xFFE64031);
    final outline = Paint()
      ..color = const Color(0xFFC8372C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final green = Paint()..color = const Color(0xFF55943C);
    final greenDark = Paint()..color = const Color(0xFF397831);
    final cream = Paint()..color = const Color(0xFFFFF2D8);
    final brown = Paint()..color = const Color(0xFF63371F);

    canvas.drawOval(const Rect.fromLTWH(34, 48, 132, 112), red);
    canvas.drawOval(const Rect.fromLTWH(34, 48, 132, 112), outline);
    canvas.drawOval(
      const Rect.fromLTWH(46, 61, 15, 32),
      Paint()..color = const Color(0xFFFF7563),
    );

    final stems = Paint()
      ..color = const Color(0xFFE64031)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final leftArm = Path()
      ..moveTo(38, 104)
      ..quadraticBezierTo(22, 97, 20, 75);
    final rightArm = Path()
      ..moveTo(162, 104)
      ..quadraticBezierTo(178, 97, 180, 75);
    canvas.drawPath(leftArm, stems);
    canvas.drawPath(rightArm, stems);

    final leafPaths = [
      Path()
        ..moveTo(100, 54)
        ..quadraticBezierTo(77, 42, 79, 24)
        ..quadraticBezierTo(97, 26, 100, 54),
      Path()
        ..moveTo(100, 54)
        ..quadraticBezierTo(107, 28, 122, 34)
        ..quadraticBezierTo(117, 51, 100, 54),
      Path()
        ..moveTo(100, 54)
        ..quadraticBezierTo(127, 46, 133, 60)
        ..quadraticBezierTo(116, 68, 100, 54),
      Path()
        ..moveTo(100, 54)
        ..quadraticBezierTo(106, 79, 95, 84)
        ..quadraticBezierTo(88, 69, 100, 54),
      Path()
        ..moveTo(100, 54)
        ..quadraticBezierTo(77, 71, 66, 61)
        ..quadraticBezierTo(80, 48, 100, 54),
    ];
    for (final leaf in leafPaths) {
      canvas.drawPath(leaf, green);
      canvas.drawPath(
        leaf,
        Paint()
          ..color = greenDark.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    canvas.drawOval(const Rect.fromLTWH(76, 91, 18, 24), brown);
    canvas.drawOval(const Rect.fromLTWH(106, 91, 18, 24), brown);
    canvas.drawCircle(const Offset(82, 98), 4, cream);
    canvas.drawCircle(const Offset(112, 98), 4, cream);
    canvas.drawCircle(
      const Offset(88, 109),
      2.5,
      Paint()..color = const Color(0xFFAA7251),
    );
    canvas.drawCircle(
      const Offset(118, 109),
      2.5,
      Paint()..color = const Color(0xFFAA7251),
    );
    canvas.drawOval(
      const Rect.fromLTWH(58, 117, 11, 5),
      Paint()..color = const Color(0xFFFF8B83),
    );
    canvas.drawOval(
      const Rect.fromLTWH(131, 117, 11, 5),
      Paint()..color = const Color(0xFFFF8B83),
    );
    canvas.drawOval(const Rect.fromLTWH(88, 119, 26, 18), brown);
    canvas.drawOval(
      const Rect.fromLTWH(92, 123, 18, 8),
      Paint()..color = const Color(0xFFFFC2A4),
    );
    canvas.drawRect(const Rect.fromLTWH(92, 121, 18, 3), cream);

    canvas.drawLine(
      const Offset(68, 155),
      const Offset(65, 173),
      Paint()
        ..color = const Color(0xFFB93227)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(132, 155),
      const Offset(135, 173),
      Paint()
        ..color = const Color(0xFFB93227)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(const Rect.fromLTWH(51, 170, 23, 10), green);
    canvas.drawOval(const Rect.fromLTWH(126, 170, 23, 10), green);

    final hand = Path()
      ..moveTo(15, 76)
      ..cubicTo(9, 73, 9, 65, 13, 61)
      ..cubicTo(17, 58, 18, 67, 20, 68)
      ..cubicTo(21, 60, 26, 61, 27, 67)
      ..cubicTo(32, 63, 34, 71, 29, 77)
      ..quadraticBezierTo(22, 83, 15, 76);
    canvas.drawPath(hand, green);
    canvas.drawPath(
      hand,
      Paint()
        ..color = greenDark.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.save();
    canvas.translate(200, 0);
    canvas.scale(-1, 1);
    canvas.drawPath(hand, green);
    canvas.drawPath(
      hand,
      Paint()
        ..color = greenDark.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
