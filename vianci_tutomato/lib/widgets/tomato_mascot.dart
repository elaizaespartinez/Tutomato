import 'dart:math' as math;

import 'package:flutter/material.dart';

// ===========================================================================
// Enums
// ===========================================================================

enum TomatoColorway {
  classic('Classic'),
  golden('Golden'),
  rosy('Rosy');

  const TomatoColorway(this.label);
  final String label;
}

enum TomatoHeadwear {
  none('None'),
  scholarHat('Scholar hat'),
  headphones('Headphones');

  const TomatoHeadwear(this.label);
  final String label;
}

enum TomatoProp {
  none('None'),
  glasses('Glasses'),
  books('Books');

  const TomatoProp(this.label);
  final String label;
}

// ===========================================================================
// Mascot
// ===========================================================================

class TomatoMascot extends StatelessWidget {
  const TomatoMascot({
    this.size = 160,
    this.colorway = TomatoColorway.classic,
    super.key,
  });

  final double size;
  final TomatoColorway colorway;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * .96,
      child: CustomPaint(painter: _TomatoPainter(colorway: colorway)),
    );
  }
}

class _TomatoPainter extends CustomPainter {
  const _TomatoPainter({this.colorway = TomatoColorway.classic});

  final TomatoColorway colorway;

  static Paint _fill(Color c) => Paint()..color = c;

  static Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 192);

    // ---------- Palette ----------
    final (
      Color bodyMain,
      Color bodyDark,
      Color bodyArm,
      Color gradLight,
      Color gradDark,
      Color bottomShade,
      Color highlight,
      Color cheekColor,
    ) = switch (colorway) {
      TomatoColorway.classic => (
        const Color(0xFFE64031),
        const Color(0xFFB93227),
        const Color(0xFFE03A2B),
        const Color(0xFFF2573F),
        const Color(0xFFCF2F26),
        const Color(0x55A82019),
        const Color(0xFFFF8A78),
        const Color(0xFFFF9A90),
      ),
      TomatoColorway.golden => (
        const Color(0xFFFFB300),
        const Color(0xFFC67D00),
        const Color(0xFFFFA000),
        const Color(0xFFFFD54F),
        const Color(0xFFFF8F00),
        const Color(0x558F5000),
        const Color(0xFFFFECB3),
        const Color(0xFFFFCC80),
      ),
      TomatoColorway.rosy => (
        const Color(0xFFE5819A),
        const Color(0xFFB34A68),
        const Color(0xFFD86B88),
        const Color(0xFFF4A6BA),
        const Color(0xFFC75574),
        const Color(0x557A2840),
        const Color(0xFFFFDDE5),
        const Color(0xFFFF9EAF),
      ),
    };

    const greenLight = Color(0xFF5FA845);
    const greenMid = Color(0xFF4F9A3A);
    const greenDeep = Color(0xFF3E8232);
    const greenLine = Color(0xFF2F6B28);
    const brown = Color(0xFF5A2E1A);
    const cream = Color(0xFFFFF6E4);

    // ---------- Ground shadow ----------
    canvas.drawOval(
      const Rect.fromLTWH(48, 169, 104, 11),
      _fill(const Color(0x14000000)),
    );

    // ---------- Legs & feet (behind body) ----------
    final leg = _stroke(bodyDark, 5);
    canvas.drawLine(const Offset(70, 150), const Offset(68, 165), leg);
    canvas.drawLine(const Offset(130, 150), const Offset(132, 165), leg);

    final footFill = _fill(greenMid);
    final footEdge = _stroke(greenLine, 1.5);
    const leftFoot = Rect.fromLTWH(55, 162, 24, 11);
    const rightFoot = Rect.fromLTWH(121, 162, 24, 11);
    for (final foot in [leftFoot, rightFoot]) {
      canvas.drawOval(foot, footFill);
      canvas.drawOval(foot, footEdge);
    }

    // ---------- Arms (behind body) ----------
    final arm = _stroke(bodyArm, 5);
    canvas.drawPath(
      Path()
        ..moveTo(34, 102)
        ..cubicTo(20, 100, 20, 88, 20, 76),
      arm,
    );
    canvas.drawPath(
      Path()
        ..moveTo(166, 102)
        ..cubicTo(180, 100, 180, 88, 180, 76),
      arm,
    );

    // ---------- Body ----------
    final body = Path()
      ..moveTo(100, 54)
      ..cubicTo(122, 43, 164, 46, 171, 86)
      ..cubicTo(177, 126, 148, 157, 100, 157)
      ..cubicTo(52, 157, 23, 126, 29, 86)
      ..cubicTo(36, 46, 78, 43, 100, 54)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: [gradLight, bodyMain, gradDark],
          stops: const [0, 0.55, 1],
        ).createShader(const Rect.fromLTWH(29, 43, 142, 114)),
    );

    // Bottom shading, clipped to the body
    canvas.save();
    canvas.clipPath(body);
    canvas.drawOval(
      const Rect.fromLTWH(10, 124, 180, 50),
      _fill(bottomShade),
    );
    canvas.restore();

    // Highlight: long crescent + small dot
    final highlightPaint = _fill(highlight);
    canvas.drawPath(
      Path()
        ..moveTo(46, 86)
        ..quadraticBezierTo(41, 67, 58, 57)
        ..quadraticBezierTo(50, 71, 53, 88)
        ..close(),
      highlightPaint,
    );
    canvas.drawOval(const Rect.fromLTWH(47, 93, 5, 7), highlightPaint);

    // ---------- Leaves (calyx) ----------
    void leaf(Path path, Paint fill, Offset veinEnd) {
      canvas.drawPath(path, fill);
      canvas.drawLine(
        const Offset(100, 55),
        veinEnd,
        _stroke(greenLine.withValues(alpha: 0.55), 1.2),
      );
    }

    leaf(
      Path()
        ..moveTo(100, 55)
        ..quadraticBezierTo(80, 33, 55, 42)
        ..quadraticBezierTo(72, 62, 100, 55),
      _fill(greenMid),
      const Offset(66, 45),
    );
    leaf(
      Path()
        ..moveTo(100, 55)
        ..quadraticBezierTo(120, 36, 143, 50)
        ..quadraticBezierTo(124, 64, 100, 55),
      _fill(greenMid),
      const Offset(133, 52),
    );
    leaf(
      Path()
        ..moveTo(100, 55)
        ..quadraticBezierTo(88, 34, 99, 13)
        ..quadraticBezierTo(113, 32, 100, 55),
      _fill(greenLight),
      const Offset(99, 22),
    );
    leaf(
      Path()
        ..moveTo(100, 55)
        ..quadraticBezierTo(87, 62, 91, 80)
        ..quadraticBezierTo(106, 72, 100, 55),
      _fill(greenDeep),
      const Offset(93, 72),
    );
    leaf(
      Path()
        ..moveTo(100, 55)
        ..quadraticBezierTo(116, 60, 116, 74)
        ..quadraticBezierTo(104, 72, 100, 55),
      _fill(greenDeep),
      const Offset(110, 66),
    );

    // ---------- Eyes ----------
    final brownPaint = _fill(brown);
    canvas.drawOval(const Rect.fromLTWH(69, 87, 18, 25), brownPaint);
    canvas.drawOval(const Rect.fromLTWH(113, 87, 18, 25), brownPaint);

    // Soft lighter lower half of each eye
    final eyeGlow = _fill(const Color(0x55B07A55));
    canvas.drawOval(const Rect.fromLTWH(72, 102, 12, 8), eyeGlow);
    canvas.drawOval(const Rect.fromLTWH(116, 102, 12, 8), eyeGlow);

    // Eye sparkles
    final sparkle = _fill(cream);
    canvas.drawCircle(const Offset(75, 94), 4.2, sparkle);
    canvas.drawCircle(const Offset(119, 94), 4.2, sparkle);
    canvas.drawCircle(const Offset(83, 105), 2, sparkle);
    canvas.drawCircle(const Offset(127, 105), 2, sparkle);

    // ---------- Cheeks (two short dashes each side) ----------
    final cheek = _stroke(cheekColor, 2.5);
    canvas.drawLine(const Offset(54, 118), const Offset(58, 113), cheek);
    canvas.drawLine(const Offset(61, 120), const Offset(65, 115), cheek);
    canvas.drawLine(const Offset(146, 118), const Offset(142, 113), cheek);
    canvas.drawLine(const Offset(139, 120), const Offset(135, 115), cheek);

    // ---------- Open smile ----------
    final mouth = Path()
      ..moveTo(85, 114)
      ..quadraticBezierTo(100, 117, 115, 114)
      ..cubicTo(114, 133, 107, 137, 100, 137)
      ..cubicTo(93, 137, 86, 133, 85, 114)
      ..close();

    canvas.drawPath(mouth, brownPaint);
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawOval(
      const Rect.fromLTWH(91, 126, 18, 12),
      _fill(const Color(0xFFFF8F7D)),
    ); // tongue
    canvas.drawRect(const Rect.fromLTWH(85, 112, 30, 7), sparkle); // teeth
    canvas.restore();

    // ---------- Hands (leaf-like, mirrored) ----------
    final hand = Path()
      ..moveTo(15, 76)
      ..cubicTo(9, 73, 9, 65, 13, 61)
      ..cubicTo(17, 58, 18, 67, 20, 68)
      ..cubicTo(21, 60, 26, 61, 27, 67)
      ..cubicTo(32, 63, 34, 71, 29, 77)
      ..quadraticBezierTo(22, 83, 15, 76);

    final handFill = _fill(greenMid);
    final handEdge = _stroke(greenLine, 1.8);

    canvas.drawPath(hand, handFill);
    canvas.drawPath(hand, handEdge);

    canvas.save();
    canvas.translate(200, 0);
    canvas.scale(-1, 1);
    canvas.drawPath(hand, handFill);
    canvas.drawPath(hand, handEdge);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TomatoPainter oldDelegate) =>
      oldDelegate.colorway != colorway;
}

// ===========================================================================
// Composite mascot with accessories
// ===========================================================================

class TomatoMascotWithAccessories extends StatelessWidget {
  const TomatoMascotWithAccessories({
    this.size = 160,
    this.colorway = TomatoColorway.classic,
    this.headwear = TomatoHeadwear.none,
    this.prop = TomatoProp.none,
    super.key,
  });

  final double size;
  final TomatoColorway colorway;
  final TomatoHeadwear headwear;
  final TomatoProp prop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TomatoMascot(size: size, colorway: colorway),
        switch (headwear) {
          TomatoHeadwear.none => const SizedBox.shrink(),
          TomatoHeadwear.scholarHat => TomatoScholarHat(size: size),
          TomatoHeadwear.headphones => TomatoHeadphones(size: size),
        },
        switch (prop) {
          TomatoProp.none => const SizedBox.shrink(),
          TomatoProp.glasses => TomatoGlasses(size: size),
          TomatoProp.books => TomatoBooks(size: size),
        },
      ],
    );
  }
}

// ===========================================================================
// Accessories
// ===========================================================================

Paint _paintFill(Color c) => Paint()..color = c;

Paint _paintStroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Base class: applies the same 200 x 192 scaling the mascot uses, so the
/// subclasses can paint in design coordinates.
abstract class _AccessoryPainter extends CustomPainter {
  const _AccessoryPainter();

  void paintAccessory(Canvas canvas);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 192);
    paintAccessory(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AccessoryLayer extends StatelessWidget {
  const _AccessoryLayer({required this.size, required this.painter});

  final double size;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size * .96,
        child: CustomPaint(painter: painter),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1) Scholar hat
// ---------------------------------------------------------------------------

class TomatoScholarHat extends StatelessWidget {
  const TomatoScholarHat({this.size = 160, super.key});

  final double size;

  @override
  Widget build(BuildContext context) =>
      _AccessoryLayer(size: size, painter: const _ScholarHatPainter());
}

class _ScholarHatPainter extends _AccessoryPainter {
  const _ScholarHatPainter();

  @override
  void paintAccessory(Canvas canvas) {
    const blackDeep = Color(0xFF141417);
    const gold = Color(0xFFE6B73C);
    const goldDark = Color(0xFF8A6414);
    final outline = _paintStroke(const Color(0xFF0E0E10), 1.6);

    // Slight jaunty tilt around the middle of the head.
    canvas.save();
    canvas.translate(100, 45);
    canvas.rotate(-0.1);
    canvas.translate(-100, -45);

    // Skull cap that sits on the head
    final skull = Path()
      ..moveTo(68, 30)
      ..lineTo(70, 52)
      ..quadraticBezierTo(100, 68, 130, 52)
      ..lineTo(132, 30)
      ..close();
    canvas.drawPath(skull, _paintFill(blackDeep));
    canvas.drawPath(skull, outline);

    // Flat board with visible thickness
    final board = Path()
      ..moveTo(34, 27)
      ..lineTo(100, 9)
      ..lineTo(166, 27)
      ..lineTo(100, 47)
      ..close();
    final underside = board.shift(const Offset(0, 5));
    canvas.drawPath(underside, _paintFill(blackDeep));
    canvas.drawPath(underside, outline);
    canvas.drawPath(
      board,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF42424A), Color(0xFF1E1E22)],
        ).createShader(const Rect.fromLTWH(34, 9, 132, 38)),
    );
    canvas.drawPath(board, outline);
    canvas.drawLine(
      const Offset(36, 27),
      const Offset(100, 10.5),
      _paintStroke(const Color(0xFF5A5A62), 1),
    );

    // Cord from the button to the right edge, then the tassel hangs down
    final cord = Path()
      ..moveTo(100, 28)
      ..quadraticBezierTo(135, 26, 152, 31.2)
      ..lineTo(152, 60);
    canvas.drawPath(cord, _paintStroke(goldDark, 3.4));
    canvas.drawPath(cord, _paintStroke(gold, 2));

    canvas.drawCircle(const Offset(100, 28), 3.2, _paintFill(gold));
    canvas.drawCircle(const Offset(100, 28), 3.2, _paintStroke(goldDark, 1.1));

    final head = RRect.fromRectAndRadius(
      const Rect.fromLTWH(148, 58, 8, 7),
      const Radius.circular(2),
    );
    canvas.drawRRect(head, _paintFill(gold));
    canvas.drawRRect(head, _paintStroke(goldDark, 1.1));
    for (var i = 0; i < 4; i++) {
      final x = 149.2 + i * 1.9;
      canvas.drawLine(Offset(x, 65), Offset(x, 79), _paintStroke(gold, 1.5));
    }

    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// 2) Over-ear headphones
// ---------------------------------------------------------------------------

class TomatoHeadphones extends StatelessWidget {
  const TomatoHeadphones({this.size = 160, super.key});

  final double size;

  @override
  Widget build(BuildContext context) =>
      _AccessoryLayer(size: size, painter: const _HeadphonesPainter());
}

class _HeadphonesPainter extends _AccessoryPainter {
  const _HeadphonesPainter();

  @override
  void paintAccessory(Canvas canvas) {
    const shell = Color(0xFF2E3440);
    const edge = Color(0xFF181B22);
    const accent = Color(0xFF59C3B0);
    const pad = Color(0xFF4A4F5C);

    // Headband: hugs the shoulders of the tomato and arcs over the calyx.
    final band = Path()
      ..moveTo(33, 86)
      ..cubicTo(26, 30, 174, 30, 167, 86);
    canvas.drawPath(band, _paintStroke(edge, 9.5));
    canvas.drawPath(band, _paintStroke(shell, 6.5));
    canvas.drawPath(
      band.shift(const Offset(0, -1.5)),
      _paintStroke(const Color(0x40FFFFFF), 1.4),
    );

    // Left ear cup; the right one is the same drawing mirrored.
    void cup() {
      final padRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(39, 98), width: 10, height: 24),
        const Radius.circular(5),
      );
      canvas.drawRRect(padRect, _paintFill(pad));
      canvas.drawRRect(padRect, _paintStroke(edge, 1.2));

      final cupRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(32, 98), width: 14, height: 30),
        const Radius.circular(7),
      );
      canvas.drawRRect(cupRect, _paintFill(shell));
      canvas.drawRRect(cupRect, _paintStroke(edge, 1.4));

      canvas.drawOval(
        Rect.fromCenter(center: const Offset(30, 98), width: 7, height: 19),
        _paintFill(accent),
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(29, 93), width: 2.5, height: 6),
        _paintFill(const Color(0x66FFFFFF)),
      );
    }

    cup();
    canvas.save();
    canvas.translate(200, 0);
    canvas.scale(-1, 1);
    cup();
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// 3) Glasses
// ---------------------------------------------------------------------------

class TomatoGlasses extends StatelessWidget {
  const TomatoGlasses({this.size = 160, super.key});

  final double size;

  @override
  Widget build(BuildContext context) =>
      _AccessoryLayer(size: size, painter: const _GlassesPainter());
}

class _GlassesPainter extends _AccessoryPainter {
  const _GlassesPainter();

  @override
  void paintAccessory(Canvas canvas) {
    const frame = Color(0xFF2B1B12);
    const radius = 16.0;
    const leftEye = Offset(77, 100);
    const rightEye = Offset(123, 100);

    // Temples (arms) running back towards the sides of the head
    final temple = _paintStroke(frame, 2.6);
    canvas.drawLine(const Offset(61.5, 97), const Offset(42, 94), temple);
    canvas.drawLine(const Offset(138.5, 97), const Offset(158, 94), temple);

    // Bridge
    canvas.drawPath(
      Path()
        ..moveTo(92, 97)
        ..quadraticBezierTo(100, 91, 108, 97),
      _paintStroke(frame, 2.6),
    );

    for (final c in const [leftEye, rightEye]) {
      // Faint glass tint, so the eyes stay visible
      canvas.drawCircle(c, radius, _paintFill(const Color(0x26FFFFFF)));
      canvas.drawCircle(c, radius, _paintStroke(frame, 3));

      // Frame sheen
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: radius),
        math.pi * 1.05,
        math.pi * 0.4,
        false,
        _paintStroke(const Color(0x59FFFFFF), 1.2),
      );

      // Glare streaks on the lens
      final glare = _paintStroke(const Color(0xB3FFFFFF), 2);
      canvas.drawLine(
        Offset(c.dx - 8, c.dy - 5),
        Offset(c.dx - 3.5, c.dy - 10),
        glare,
      );
      canvas.drawLine(
        Offset(c.dx - 9.5, c.dy),
        Offset(c.dx - 8.5, c.dy - 2),
        glare,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 4) Books held in the raised hand
// ---------------------------------------------------------------------------

class TomatoBooks extends StatelessWidget {
  const TomatoBooks({this.size = 160, this.mirrored = false, super.key});

  final double size;

  /// By default the books are held in the hand on the right of the canvas.
  /// Set to true to put them in the hand on the left instead.
  final bool mirrored;

  @override
  Widget build(BuildContext context) =>
      _AccessoryLayer(size: size, painter: _BooksPainter(mirrored: mirrored));
}

class _BooksPainter extends _AccessoryPainter {
  const _BooksPainter({this.mirrored = false});

  final bool mirrored;

  @override
  void paintAccessory(Canvas canvas) {
    canvas.save();
    if (mirrored) {
      canvas.translate(200, 0);
      canvas.scale(-1, 1);
    }

    _paintStack(canvas);
    _paintGrippingHand(canvas);

    canvas.restore();
  }

  void _paintStack(Canvas canvas) {
    canvas.save();
    canvas.translate(176, 52);
    canvas.rotate(0.1);
    canvas.translate(-176, -52);

    void book(Rect r, Color cover) {
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(2));
      canvas.drawRRect(rr, _paintFill(cover));

      // Page block on the side facing the body
      final pages = Rect.fromLTWH(r.left + 1.5, r.top + 1.5, 7, r.height - 3);
      canvas.drawRect(pages, _paintFill(const Color(0xFFFFF6E4)));
      canvas.drawLine(
        Offset(pages.left, r.center.dy),
        Offset(pages.right, r.center.dy),
        _paintStroke(const Color(0x55A07A4A), 0.7),
      );

      // Gold band on the spine
      canvas.drawLine(
        Offset(r.right - 5, r.top + 1.5),
        Offset(r.right - 5, r.bottom - 1.5),
        _paintStroke(const Color(0xFFE6B73C), 1.1),
      );

      canvas.drawRRect(rr, _paintStroke(const Color(0xFF2A1A12), 1.2));
    }

    book(const Rect.fromLTWH(160, 57, 32, 9), const Color(0xFF2F7F79));
    book(const Rect.fromLTWH(163, 48, 30, 9), const Color(0xFFB58A5C));
    book(const Rect.fromLTWH(159, 39, 32, 9), const Color(0xFF3D5F8C));

    canvas.restore();
  }

  /// Re-draws the mascot's own raised hand on top of the books so the
  /// fingers wrap in front of them (same path and colors as the mascot).
  void _paintGrippingHand(Canvas canvas) {
    final hand = Path()
      ..moveTo(15, 76)
      ..cubicTo(9, 73, 9, 65, 13, 61)
      ..cubicTo(17, 58, 18, 67, 20, 68)
      ..cubicTo(21, 60, 26, 61, 27, 67)
      ..cubicTo(32, 63, 34, 71, 29, 77)
      ..quadraticBezierTo(22, 83, 15, 76);

    canvas.save();
    canvas.translate(200, 0);
    canvas.scale(-1, 1);
    canvas.drawPath(hand, _paintFill(const Color(0xFF4F9A3A)));
    canvas.drawPath(hand, _paintStroke(const Color(0xFF2F6B28), 1.8));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BooksPainter oldDelegate) =>
      oldDelegate.mirrored != mirrored;
}
