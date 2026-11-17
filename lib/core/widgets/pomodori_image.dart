import 'dart:math' as math;

import 'package:flutter/material.dart';

enum PomodoriMood { happy, sleepy, sad }

/// Shows the tomato character from assets/images/<asset>.png.
/// If that file doesn't exist yet, a simple drawn tomato is shown instead.
class PomodoriImage extends StatelessWidget {
  final String asset; // file name without ".png"
  final double size;
  final PomodoriMood mood;
  final Color body;

  const PomodoriImage({
    super.key,
    this.asset = 'pomodori_happy',
    this.size = 120,
    this.mood = PomodoriMood.happy,
    this.body = const Color(0xFFE5452F),
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Image.asset(
      'assets/images/$asset.png', //placeholder -- wala pang laman
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) =>
          CustomPaint(painter: TomatoPainter(mood, body)),
    ),
  );
}

/// Draws a friendly tomato (used until the real artwork is added).
class TomatoPainter extends CustomPainter {
  final PomodoriMood mood;
  final Color body;
  TomatoPainter(this.mood, this.body);

  static const _ink = Color(0xFF5A2410);
  static const _leafLight = Color(0xFF5FA03F);
  static const _leafDark = Color(0xFF3E7A2A);

  /// Squat tomato shape with a small dip at the top.
  Path _bodyPath(double cx, double cy, double rx, double ry) {
    final top = cy - ry;
    final bottom = cy + ry;
    return Path()
      ..moveTo(cx, top + ry * 0.12)
      ..cubicTo(cx + rx * 0.30, top - ry * 0.08, cx + rx, top + ry * 0.05,
          cx + rx, cy)
      ..cubicTo(cx + rx, cy + ry * 0.65, cx + rx * 0.55, bottom, cx, bottom)
      ..cubicTo(cx - rx * 0.55, bottom, cx - rx, cy + ry * 0.65, cx - rx, cy)
      ..cubicTo(cx - rx, top + ry * 0.05, cx - rx * 0.30, top - ry * 0.08, cx,
          top + ry * 0.12)
      ..close();
  }

  /// Little green hand with three finger bumps.
  void _hand(Canvas canvas, Offset p, double s) {
    final paint = Paint()..color = _leafLight;
    canvas.drawOval(
      Rect.fromCenter(
        center: p.translate(0, -s * 0.01),
        width: s * 0.065,
        height: s * 0.06,
      ),
      paint,
    );
    for (final a in [-0.55, 0.0, 0.55]) {
      canvas.save();
      canvas.translate(p.dx, p.dy - s * 0.03);
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -s * 0.02),
          width: s * 0.03,
          height: s * 0.055,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final cx = w / 2;
    final cy = h * 0.50;
    final rx = s * 0.33;
    final ry = s * 0.285;
    final top = cy - ry;
    final bottom = cy + ry;
    final dark = Color.lerp(body, Colors.black, 0.2)!;

    // ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bottom + s * 0.095),
        width: s * 0.6,
        height: s * 0.05,
      ),
      Paint()..color = const Color(0x22000000),
    );

    // arms (raised) + hands, drawn behind the body
    final limb = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    for (final dx in [-1.0, 1.0]) {
      final arm = Path()
        ..moveTo(cx + dx * rx * 0.9, cy + ry * 0.1)
        ..quadraticBezierTo(
          cx + dx * rx * 1.22,
          cy + ry * 0.05,
          cx + dx * rx * 1.2,
          cy - ry * 0.5,
        );
      canvas.drawPath(arm, limb);
      _hand(canvas, Offset(cx + dx * rx * 1.2, cy - ry * 0.55), s);
    }

    // legs + green shoes
    final legPaint = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    for (final dx in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(cx + dx * s * 0.1, bottom - s * 0.03),
        Offset(cx + dx * s * 0.1, bottom + s * 0.08),
        legPaint,
      );
      final shoe = Offset(cx + dx * s * 0.115, bottom + s * 0.09);
      canvas.drawOval(
        Rect.fromCenter(center: shoe, width: s * 0.14, height: s * 0.055),
        Paint()..color = _leafDark,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: shoe.translate(0, -s * 0.007),
          width: s * 0.125,
          height: s * 0.04,
        ),
        Paint()..color = _leafLight,
      );
    }

    // body with a darker rim at the bottom/right
    final bodyPath = _bodyPath(cx, cy, rx, ry);
    canvas.drawPath(bodyPath, Paint()..color = dark);
    canvas.save();
    canvas.clipPath(bodyPath);
    canvas.drawPath(
      bodyPath.shift(Offset(-s * 0.018, -s * 0.022)),
      Paint()..color = body,
    );
    canvas.restore();

    // shine
    const shine = Color(0x66FFFFFF);
    canvas.save();
    canvas.translate(cx - rx * 0.58, cy - ry * 0.5);
    canvas.rotate(-0.65);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 0.34, height: ry * 0.2),
      Paint()..color = shine,
    );
    canvas.restore();
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - rx * 0.85, cy + ry * 0.05),
        width: rx * 0.07,
        height: ry * 0.12,
      ),
      Paint()..color = shine,
    );

    // star-shaped green calyx (angle, length as a fraction of size)
    final calyxY = top + ry * 0.1;
    const leaves = [
      [-2.3, 0.10],
      [2.3, 0.10],
      [-1.6, 0.13],
      [1.6, 0.13],
      [-0.85, 0.15],
      [0.85, 0.15],
      [0.0, 0.17],
    ];
    for (final l in leaves) {
      final len = s * l[1];
      final wid = len * 0.32;
      canvas.save();
      canvas.translate(cx, calyxY);
      canvas.rotate(l[0]);
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(wid * 1.6, -len * 0.5, 0, -len)
        ..quadraticBezierTo(-wid * 1.6, -len * 0.5, 0, 0);
      canvas.drawPath(leaf, Paint()..color = _leafLight);
      canvas.drawLine(
        Offset(0, -len * 0.1),
        Offset(0, -len * 0.8),
        Paint()
          ..color = _leafDark
          ..strokeWidth = s * 0.008
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }
    canvas.drawCircle(
      Offset(cx, calyxY),
      s * 0.02,
      Paint()..color = _leafDark,
    );

    // eyes, cheeks, tears
    final eyeY = cy - ry * 0.03;
    final eyeDx = rx * 0.4;
    final er = rx * 0.14;
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.014
      ..strokeCap = StrokeCap.round;
    final cheek = Paint()
      ..color = const Color(0x99FFB3A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012
      ..strokeCap = StrokeCap.round;

    for (final dx in [-1.0, 1.0]) {
      final eye = Offset(cx + dx * eyeDx, eyeY);
      if (mood == PomodoriMood.sleepy) {
        canvas.drawArc(
          Rect.fromCenter(center: eye, width: er * 2.2, height: er * 1.4),
          0,
          math.pi,
          false,
          stroke,
        );
      } else {
        canvas.drawCircle(eye, er, Paint()..color = _ink);
        canvas.drawCircle(
          eye.translate(-er * 0.3, -er * 0.35),
          er * 0.38,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          eye.translate(er * 0.3, er * 0.35),
          er * 0.18,
          Paint()..color = Colors.white,
        );
      }

      // cheek slashes
      final cheekBase = Offset(cx + dx * rx * 0.72, cy + ry * 0.22);
      for (final i in [0, 1]) {
        final x = cheekBase.dx + (i - 0.5) * s * 0.03;
        canvas.drawLine(
          Offset(x - s * 0.008, cheekBase.dy + s * 0.014),
          Offset(x + s * 0.008, cheekBase.dy - s * 0.014),
          cheek,
        );
      }

      if (mood == PomodoriMood.sad) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(eye.dx, eye.dy + er * 2.2),
            width: er * 0.7,
            height: er * 1.2,
          ),
          Paint()..color = const Color(0xFF7CC6E8),
        );
      }
    }

    // mouth
    switch (mood) {
      case PomodoriMood.happy:
        final mw = rx * 0.62;
        final mh = ry * 0.36;
        final rect = Rect.fromCenter(
          center: Offset(cx, cy + ry * 0.14),
          width: mw,
          height: mh * 2,
        );
        final mouth = Path()
          ..addArc(rect, 0, math.pi)
          ..close();
        canvas.drawPath(mouth, Paint()..color = _ink);
        canvas.save();
        canvas.clipPath(mouth);
        // teeth
        canvas.drawRect(
          Rect.fromLTWH(cx - mw / 2, rect.center.dy, mw, mh * 0.28),
          Paint()..color = Colors.white,
        );
        // tongue
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, rect.center.dy + mh * 0.95),
            width: mw * 0.6,
            height: mh * 0.7,
          ),
          Paint()..color = const Color(0xFFFF8FA0),
        );
        canvas.restore();
      case PomodoriMood.sleepy:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx, cy + ry * 0.22),
            width: rx * 0.22,
            height: ry * 0.14,
          ),
          0,
          math.pi,
          false,
          stroke,
        );
      case PomodoriMood.sad:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx, cy + ry * 0.42),
            width: rx * 0.3,
            height: ry * 0.2,
          ),
          math.pi,
          math.pi,
          false,
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(TomatoPainter old) => old.mood != mood || old.body != body;
}