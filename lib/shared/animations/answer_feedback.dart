import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../widgets/ink_shadow.dart';

/// Estado visual de uma alternativa de resposta.
enum AnswerState { idle, selected, correct, incorrect }

/// Pílula de resposta estilo "quadrinho": borda preta e sombra sólida
/// sempre presentes; o fundo vira verde sólido ao acertar e vermelho sólido
/// ao errar.
class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({super.key, required this.state, required this.child});

  final AnswerState state;
  final Widget child;

  Color get _backgroundColor {
    switch (state) {
      case AnswerState.correct:
        return AppColors.primary;
      case AnswerState.incorrect:
        return AppColors.error;
      case AnswerState.selected:
      case AnswerState.idle:
        return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceMd,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: inkShadow(dx: 4, dy: 4),
      ),
      child: child,
    );
  }
}
