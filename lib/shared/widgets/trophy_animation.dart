import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Troféu animado (estrela do selo + copo, confete, raios e brilhos),
/// em loop. Pensado para ser colocado dentro de uma página já existente
/// (por isso não pinta um fundo próprio — herda o fundo de quem o usa).
class TrophyAnimation extends StatefulWidget {
  const TrophyAnimation({super.key, this.size = 220});

  final double size;

  @override
  State<TrophyAnimation> createState() => _TrophyAnimationState();
}

class _TrophyAnimationState extends State<TrophyAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(painter: _TrophyPainter(_controller.value)),
      ),
    );
  }
}

class _TrophyPainter extends CustomPainter {
  final double t;
  _TrophyPainter(this.t);

  static const purple2 = Color(0xFF8A43FF);
  static const pink = Color(0xFF18A957);
  static const blue = Color(0xFF61A8FF);
  static const yellow = Color(0xFFFFE84D);
  static const gold = Color(0xFFFFB928);
  static const orange = Color(0xFFFF6A24);
  static const white = Color(0xFFFFF7E7);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;

    final entrance = Curves.easeOutBack.transform(((t * 1.65).clamp(0.0, 1.0)));
    final fade = Curves.easeOut.transform(((t * 2.0).clamp(0.0, 1.0)));

    // Raios aparecem lentamente atrás do selo.
    final rayOpacity = Curves.easeOut.transform(((t - .08) / .55).clamp(0.0, 1.0));
    _drawRays(canvas, c, s, rayOpacity);

    // Confete começa logo no início e se estabiliza.
    _drawConfetti(canvas, c, s, t);

    canvas.save();
    final scale = .62 + .38 * entrance;
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale);
    canvas.translate(-c.dx, -c.dy);

    _drawBadge(canvas, c, s, fade);
    _drawTrophy(canvas, c, s, fade);

    canvas.restore();

    // Pequenos brilhos pulsam durante todo o loop.
    _drawSparkles(canvas, c, s, t);
  }

  void _drawRays(Canvas canvas, Offset c, double s, double opacity) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFD95A).withValues(alpha: .20 * opacity);

    for (int i = 0; i < 20; i++) {
      final a = i * math.pi * 2 / 20;
      final len = s * (.34 + (i.isEven ? .16 : .08));
      final inner = s * .13;
      final width = i.isEven ? .035 : .018;

      final p1 = Offset(c.dx + math.cos(a - width) * inner, c.dy + math.sin(a - width) * inner);
      final p2 = Offset(c.dx + math.cos(a + width) * inner, c.dy + math.sin(a + width) * inner);
      final p3 = Offset(c.dx + math.cos(a + width) * len, c.dy + math.sin(a + width) * len);
      final p4 = Offset(c.dx + math.cos(a - width) * len, c.dy + math.sin(a - width) * len);

      canvas.drawPath(
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close(),
        paint,
      );
    }
  }

  void _drawBadge(Canvas canvas, Offset c, double s, double opacity) {
    final r = s * .285;

    _star(canvas, c.translate(0, s * .005), r * 1.12, r * .50, 8, Paint()..color = pink.withValues(alpha: opacity));
    _star(canvas, c.translate(0, -s * .005), r * 1.05, r * .52, 10, Paint()..color = gold.withValues(alpha: opacity));

    _star(
      canvas,
      c.translate(0, s * .015),
      r,
      r * .47,
      8,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A4CFF), Color(0xFF5120E8)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .009
      ..color = const Color(0xFFB79CFF).withValues(alpha: opacity);
    _starPath(c.translate(0, s * .015), r * .91, r * .43, 8, outline, canvas);

    final shield = Path()
      ..moveTo(c.dx, c.dy - r * .78)
      ..lineTo(c.dx + r * .48, c.dy - r * .45)
      ..lineTo(c.dx + r * .40, c.dy + r * .35)
      ..lineTo(c.dx, c.dy + r * .70)
      ..lineTo(c.dx - r * .40, c.dy + r * .35)
      ..lineTo(c.dx - r * .48, c.dy - r * .45)
      ..close();

    canvas.drawPath(
      shield,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pink, Color(0xFF18A957)],
        ).createShader(Rect.fromCenter(center: c, width: r, height: r * 1.6)),
    );

    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r * .63)
        ..lineTo(c.dx + r * .25, c.dy - r * .45)
        ..lineTo(c.dx + r * .18, c.dy + r * .20)
        ..lineTo(c.dx, c.dy + r * .43)
        ..close(),
      Paint()..color = const Color(0xFFAFD4FF).withValues(alpha: .45 * opacity),
    );

    _star(canvas, c.translate(0, -r * .42), r * .15, r * .065, 4, Paint()..color = yellow.withValues(alpha: opacity));
  }

  void _drawTrophy(Canvas canvas, Offset c, double s, double opacity) {
    final r = s * .285;

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFD12E).withValues(alpha: .30 * opacity), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c.translate(0, r * .25), radius: r * .75));
    canvas.drawCircle(c.translate(0, r * .25), r * .75, glow);

    final handlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .16
      ..strokeCap = StrokeCap.round
      ..color = gold.withValues(alpha: opacity);

    final leftHandle = Path()
      ..moveTo(c.dx - r * .50, c.dy + r * .00)
      ..cubicTo(c.dx - r * .92, c.dy - r * .05, c.dx - r * .88, c.dy + r * .48, c.dx - r * .45, c.dy + r * .43);
    final rightHandle = Path()
      ..moveTo(c.dx + r * .50, c.dy + r * .00)
      ..cubicTo(c.dx + r * .92, c.dy - r * .05, c.dx + r * .88, c.dy + r * .48, c.dx + r * .45, c.dy + r * .43);
    canvas.drawPath(leftHandle, handlePaint);
    canvas.drawPath(rightHandle, handlePaint);

    final cup = Path()
      ..moveTo(c.dx - r * .52, c.dy - r * .02)
      ..lineTo(c.dx + r * .52, c.dy - r * .02)
      ..lineTo(c.dx + r * .36, c.dy + r * .40)
      ..quadraticBezierTo(c.dx, c.dy + r * .62, c.dx - r * .36, c.dy + r * .40)
      ..close();

    canvas.drawPath(
      cup,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE84D), Color(0xFFFF9B20)],
        ).createShader(Rect.fromCenter(center: c.translate(0, r * .2), width: r, height: r)),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, -r * .01), width: r * 1.13, height: r * .22),
        Radius.circular(r * .08),
      ),
      Paint()..color = yellow.withValues(alpha: opacity),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(-r * .15, r * .19), width: r * .18, height: r * .44),
        Radius.circular(r * .03),
      ),
      Paint()..color = white.withValues(alpha: .55 * opacity),
    );

    canvas.drawRect(
      Rect.fromCenter(center: c.translate(0, r * .57), width: r * .16, height: r * .30),
      Paint()..color = orange.withValues(alpha: opacity),
    );

    final base = Path()
      ..moveTo(c.dx - r * .23, c.dy + r * .62)
      ..lineTo(c.dx + r * .23, c.dy + r * .62)
      ..lineTo(c.dx, c.dy + r * .93)
      ..close();
    canvas.drawPath(
      base,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFB52A), Color(0xFFFF7023)],
        ).createShader(Rect.fromCenter(center: c.translate(0, r * .75), width: r * .5, height: r * .5)),
    );
  }

  void _drawConfetti(Canvas canvas, Offset c, double s, double t) {
    final colors = [pink, yellow, purple2, orange, blue];
    const count = 55;

    for (int i = 0; i < count; i++) {
      final seed = i * 97.31;
      final a = ((seed % 628) / 100);
      final baseR = s * (.22 + ((seed * 13) % 100) / 100 * .30);
      final drift = math.sin(t * math.pi * 2 + seed) * s * .015;
      final rr = baseR + drift;

      final x = c.dx + math.cos(a) * rr;
      final y = c.dy + math.sin(a) * rr;

      final local = ((t * 2.2 + (i % 9) / 9) % 1.0);
      final alpha = (local < .12 ? local / .12 : 1.0) * (1.0 - .18 * math.max(0, math.sin(t * math.pi)));

      final p = Paint()
        ..color = colors[i % colors.length].withValues(alpha: alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final w = s * (.008 + (i % 3) * .003);
      final h = s * (.025 + (i % 4) * .008);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((seed % 3.14) + t * .7);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w, height: h), p);
      canvas.restore();
    }
  }

  void _drawSparkles(Canvas canvas, Offset c, double s, double t) {
    final points = [
      const Offset(-.39, -.34),
      const Offset(.40, -.38),
      const Offset(.46, .28),
      const Offset(-.43, .33),
    ];

    for (int i = 0; i < points.length; i++) {
      final pulse = .55 + .45 * math.sin(t * math.pi * 2 * 1.4 + i);
      final p = c + Offset(points[i].dx * s, points[i].dy * s);
      _star(canvas, p, s * .025 * pulse, s * .010 * pulse, 4, Paint()..color = yellow.withValues(alpha: .85));
    }
  }

  void _star(Canvas canvas, Offset center, double outer, double inner, int points, Paint paint) {
    _starPath(center, outer, inner, points, paint, canvas);
  }

  void _starPath(Offset center, double outer, double inner, int points, Paint paint, Canvas canvas) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / points;
      final p = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrophyPainter oldDelegate) => oldDelegate.t != t;
}
