import 'dart:math';
import 'package:flutter/material.dart';

/// Faz o filho cair de cima com uma leve rotação e "quicar" até assentar
/// (estilo confete/figurinhas caindo), depois entra num balanço contínuo e
/// sutil — igual ao efeito de decorações caindo em telas de onboarding.
class FallAndSettle extends StatefulWidget {
  const FallAndSettle({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.fallDuration = const Duration(milliseconds: 700),
    this.dropHeight = 90,
    this.startAngle = 0.35,
  });

  final Widget child;
  final Duration delay;
  final Duration fallDuration;
  final double dropHeight;

  /// Ângulo inicial (radianos) antes de assentar em 0. Alterne o sinal entre
  /// elementos vizinhos para o balanço não parecer sincronizado.
  final double startAngle;

  @override
  State<FallAndSettle> createState() => _FallAndSettleState();
}

class _FallAndSettleState extends State<FallAndSettle> with TickerProviderStateMixin {
  late final AnimationController _fallController;
  late final AnimationController _idleController;
  late final Animation<double> _fall;

  @override
  void initState() {
    super.initState();
    _fallController = AnimationController(vsync: this, duration: widget.fallDuration);
    _fall = CurvedAnimation(parent: _fallController, curve: Curves.easeOutBack);
    _idleController = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    Future.delayed(widget.delay, () {
      if (!mounted) return;
      _fallController.forward().then((_) {
        if (mounted) _idleController.repeat(reverse: true);
      });
    });
  }

  @override
  void dispose() {
    _fallController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fallController, _idleController]),
      builder: (context, child) {
        final fallValue = _fall.value;
        final idleWiggle = sin(_idleController.value * pi) * 0.05;
        final angle = widget.startAngle * (1 - fallValue) + idleWiggle;

        return Opacity(
          opacity: fallValue.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, widget.dropHeight * (1 - fallValue)),
            child: Transform.rotate(angle: angle, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
