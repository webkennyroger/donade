import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/animations/answer_feedback.dart';

class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.optionLetter,
    required this.state,
    required this.onTap,
  });

  final String label;
  final String optionLetter;
  final AnswerState state;
  final VoidCallback onTap;

  bool get _isRevealed => state == AnswerState.correct || state == AnswerState.incorrect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnswerFeedback(
        state: state,
        child: Row(
          children: [
            // Círculo cinza da letra (A/B/C). Aumentar `width`/`height` aqui
            // também deixa a pílula mais alta (a altura da pílula é definida
            // pelo maior item da Row + o padding do AnswerFeedback, no
            // arquivo answer_feedback.dart).
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFF6F6B67), shape: BoxShape.circle),
              child: Text(
                optionLetter,
                style: const TextStyle(
                  // Tamanho da letra (A/B/C) dentro do círculo.
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMd),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  // Tamanho do texto da resposta ("De 90.000 a 100.000").
                  fontFamily: 'NotoSans',
                  fontSize: 22,
                  color: _isRevealed ? AppColors.white : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
