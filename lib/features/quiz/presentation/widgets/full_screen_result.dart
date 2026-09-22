import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/ink_shadow.dart';

/// Tela cheia de transição mostrada por alguns instantes depois de
/// responder, antes de avançar para a próxima pergunta.
class FullScreenResult extends StatelessWidget {
  const FullScreenResult({super.key, required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF05893A) : const Color(0xFFE31E24);
    return Scaffold(
      backgroundColor: color,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 3),
                boxShadow: inkShadow(dx: 6, dy: 6),
              ),
              child: Icon(isCorrect ? Icons.check : Icons.close, color: color, size: 76),
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
