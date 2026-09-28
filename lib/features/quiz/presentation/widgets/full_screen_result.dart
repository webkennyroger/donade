import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/ink_shadow.dart';

const _decor = 'assets/images/decorations';

/// Tela cheia de transição mostrada por alguns instantes depois de
/// responder, antes de avançar para a próxima pergunta.
class FullScreenResult extends StatelessWidget {
  const FullScreenResult({super.key, required this.isCorrect});

  final bool isCorrect;

  // Tamanho bem grande de propósito — é o destaque da tela cheia. Mude
  // livremente; `acertou.svg` já é o círculo completo (fica com esse
  // tamanho exato), e o círculo do "errou" (feito aqui) mais o `errou.svg`
  // por dentro dele escalam junto.
  static const _circleSize = 220.0;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF05893A) : const Color(0xFFE31E24);
    return Scaffold(
      backgroundColor: color,
      body: Center(
        child: Column(
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
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 3),
                  boxShadow: inkShadow(dx: 6, dy: 6),
                ),
                // O arquivo `errou.svg` tem a cor branca fixa; num círculo
                // branco ele ficaria invisível, então tingimos ele da cor
                // vermelha da página.
                child: SvgPicture.asset(
                  '$_decor/errou.svg',
                  width: _circleSize * 0.5,
                  height: _circleSize * 0.5,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            const SizedBox(height: 32),
            Text(
              isCorrect ? 'VOCÊ\nACERTOU!' : 'VOCÊ\nERROU!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w700,
                fontSize: 40,
                height: 1.1,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
