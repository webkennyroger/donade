import 'dart:math';
import 'package:flutter/material.dart';

/// Entrada deslizando de cima (com fade) e, depois de assentar, um balanço
/// horizontal lento e contínuo — usado em elementos largos de fundo como a
/// onda decorativa, que não combinam com o "quique" do [FallAndSettle].
class SlideDownSway extends StatefulWidget {
  const SlideDownSway({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.enterDuration = const Duration(milliseconds: 700),
    this.dropHeight = 60,
    this.swayAmount = 10,
    this.swayDuration = const Duration(seconds: 5),
  });

  final Widget child;
  final Duration delay;
  final Duration enterDuration;
  final double dropHeight;
  final double swayAmount;
  final Duration swayDuration;

  @override
  State<SlideDownSway> createState() => _SlideDownSwayState();
}

class _SlideDownSwayState extends State<SlideDownSway> with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _swayController;
  late final Animation<double> _enter;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(vsync: this, duration: widget.enterDuration);
    _enter = CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic);
    _swayController = AnimationController(vsync: this, duration: widget.swayDuration);

    Future.delayed(widget.delay, () {
      if (!mounted) return;
      _enterController.forward().then((_) {
        if (mounted) _swayController.repeat();
      });
    });
  }

  @override
  void dispose() {
    _enterController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enterController, _swayController]),
      builder: (context, child) {
        final sway = sin(_swayController.value * 2 * pi) * widget.swayAmount;
        return Opacity(
          opacity: _enter.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(sway, widget.dropHeight * (1 - _enter.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
