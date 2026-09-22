import 'package:flutter/material.dart';

/// Anima a entrada de um widget com fade + slide vertical + escala leve.
/// Usado nos cards da Home e nos elementos da tela de pergunta.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.offsetY = 24,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Interval(
        _delayFraction(),
        1.0,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - value)),
            child: Transform.scale(
              scale: 0.96 + (0.04 * value),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  double _delayFraction() {
    final total = (duration + delay).inMilliseconds;
    if (total == 0) return 0;
    return (delay.inMilliseconds / total).clamp(0.0, 0.99);
  }
}
