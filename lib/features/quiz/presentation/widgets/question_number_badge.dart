import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/ink_shadow.dart';

/// Círculo branco com o número da pergunta, com o risco decorativo atrás,
/// igual ao selo da referência.
class QuestionNumberBadge extends StatelessWidget {
  const QuestionNumberBadge({super.key, required this.number, this.size = 76});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 20,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -size * 0.35,
            right: -6,
            child: SvgPicture.asset(
              'assets/images/decorations/elemento-risco.svg',
              width: size * 0.6,
            ),
          ),
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 3),
              boxShadow: inkShadow(dx: 4, dy: 4),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w700,
                fontSize: size * 0.56,
                color: AppColors.ink,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
