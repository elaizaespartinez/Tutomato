import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pomodori_image.dart';

class PomodoriAvatar extends StatelessWidget {
  final double size;
  final String color;
  final String outfit;
  final String extra;

  const PomodoriAvatar({
    super.key,
    this.size = 160,
    this.color = 'classic',
    this.outfit = 'classic',
    this.extra = 'none',
  });

  static String cleanKey(String key) {
    if (key.contains('_')) {
      return key.substring(key.indexOf('_') + 1);
    }
    return key;
  }

  static Color bodyOf(String color) {
    final clean = cleanKey(color);
    switch (clean) {
      case 'golden':
        return const Color(0xFFE6B02E);
      case 'rosy':
        return const Color(0xFFE02F78);
      default:
        return const Color(0xFFE5452F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cKey = cleanKey(color);
    final oKey = cleanKey(outfit);
    final eKey = cleanKey(extra);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PomodoriImage(
            asset: cKey == 'classic' ? 'pomodori_happy' : 'pomodori_$cKey',
            size: size,
            body: bodyOf(cKey),
          ),
          if (oKey != 'classic')
            _Accessory(asset: 'outfit_$oKey', kind: oKey),
          if (eKey != 'none')
            _Accessory(asset: 'extra_$eKey', kind: eKey),
        ],
      ),
    );
  }
}

class _Accessory extends StatelessWidget {
  final String asset;
  final String kind;
  const _Accessory({required this.asset, required this.kind});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$asset.png',
    fit: BoxFit.contain,
    errorBuilder: (context, error, stack) =>
        CustomPaint(painter: _AccessoryPainter(kind)),
  );
}

class _AccessoryPainter extends CustomPainter {
  final String kind;
  _AccessoryPainter(this.kind);

  static const _ink = Color(0xFF3A1A0E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h * 0.56);
    final r = w * 0.36;
    final fill = Paint()..color = _ink;
    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;

    switch (kind) {
      case 'scholar':
        final top = c.dy - r * 0.9;
        final board = Path()
          ..moveTo(c.dx - r * 0.75, top)
          ..lineTo(c.dx, top - r * 0.28)
          ..lineTo(c.dx + r * 0.75, top)
          ..lineTo(c.dx, top + r * 0.22)
          ..close();
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(c.dx - r * 0.34, top + r * 0.05, r * 0.68, r * 0.3),
            Radius.circular(r * 0.08),
          ),
          fill,
        );
        canvas.drawPath(board, fill);
        canvas.drawLine(
          Offset(c.dx + r * 0.6, top + r * 0.02),
          Offset(c.dx + r * 0.6, top + r * 0.45),
          line,
        );
      case 'cozy':
        final band = Paint()
          ..color = _ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.12
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy - r * 0.05),
            width: r * 2.05,
            height: r * 1.9,
          ),
          math.pi,
          math.pi,
          false,
          band,
        );
        final cup = Paint()..color = const Color(0xFFBEE3EF);
        for (final dx in [-1.0, 1.0]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(c.dx + dx * r * 1.02, c.dy - r * 0.05),
                width: r * 0.3,
                height: r * 0.55,
              ),
              Radius.circular(r * 0.12),
            ),
            cup,
          );
        }
      case 'glasses':
        final eyeY = c.dy - r * 0.05;
        for (final dx in [-1.0, 1.0]) {
          canvas.drawCircle(Offset(c.dx + dx * r * 0.35, eyeY), r * 0.2, line);
        }
        canvas.drawLine(
          Offset(c.dx - r * 0.15, eyeY),
          Offset(c.dx + r * 0.15, eyeY),
          line,
        );
      case 'book':
        final rect = Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.78),
          width: r * 1.0,
          height: r * 0.62,
        );
        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r * 0.06));
        canvas.drawRRect(rrect, Paint()..color = Colors.white);
        canvas.drawRRect(rrect, line);
        canvas.drawLine(rect.topCenter, rect.bottomCenter, line);
    }
  }

  @override
  bool shouldRepaint(_AccessoryPainter old) => old.kind != kind;
}