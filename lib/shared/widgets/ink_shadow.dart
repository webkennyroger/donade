import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Sombra sólida (sem blur) atrás de uma forma, imitando o contorno duplo
/// dos recortes em papel usados no estilo "quadrinho" do app (cartão da
/// Onboarding, cartão de pergunta, pílulas de resposta, círculos).
List<BoxShadow> inkShadow({double dx = 6, double dy = 6, Color color = AppColors.ink}) {
  return [BoxShadow(color: color, offset: Offset(dx, dy))];
}
