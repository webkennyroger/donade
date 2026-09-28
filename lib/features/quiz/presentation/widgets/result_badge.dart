import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/ink_shadow.dart';

const _decor = 'assets/images/decorations';

/// Selo "VOCÊ ACERTOU!"/"VOCÊ ERROU!" que aparece no canto do cartão de
/// pergunta assim que o usuário responde, no lugar do splash decorativo.
class ResultBadge extends StatelessWidget {
  const ResultBadge({super.key, required this.isCorrect});

  final bool isCorrect;

  // Tamanho do círculo do selo. `acertou.svg` já é o círculo completo
  // (verde, com o check); `errou.svg` é só o "X" branco, então continua
  // sendo desenhado por cima de um círculo vermelho feito aqui mesmo.
  static const _circleSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.primary : AppColors.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCorrect)
          SvgPicture.asset('$_decor/acertou.svg', width: _circleSize, height: _circleSize)
        else
          Container(
            width: _circleSize,
            height: _circleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: inkShadow(dx: 3, dy: 3),
            ),
            child: SvgPicture.asset('$_decor/errou.svg', width: 22, height: 22),
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
