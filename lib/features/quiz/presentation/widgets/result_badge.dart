import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/ink_shadow.dart';

/// Selo "VOCÊ ACERTOU!"/"VOCÊ ERROU!" que aparece no canto do cartão de
/// pergunta assim que o usuário responde, no lugar do splash decorativo.
class ResultBadge extends StatelessWidget {
  const ResultBadge({super.key, required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.primary : AppColors.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: inkShadow(dx: 3, dy: 3),
          ),
          child: Icon(isCorrect ? Icons.check : Icons.close, color: color, size: 26),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        Text(
          isCorrect ? 'VOCÊ\nACERTOU!' : 'VOCÊ\nERROU!',
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.05,
            color: color,
          ),
        ),
      ],
    );
  }
}
