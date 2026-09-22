import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone em SVG do kit visual. [name] é o arquivo dentro de
/// assets/images/icons/ (sem extensão), ex.: 'arrow_right', 'check'.
class AppIcon extends StatelessWidget {
  const AppIcon({super.key, required this.name, this.size = 20, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      placeholderBuilder: (context) => SizedBox(width: size, height: size),
    );
  }
}
