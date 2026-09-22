import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Elemento decorativo (onda, blob, squiggle, sparkle). [name] é o arquivo
/// dentro de assets/images/decorations/ (sem extensão, sempre .svg).
class DecorAsset extends StatelessWidget {
  const DecorAsset({super.key, required this.name, this.width});

  final String name;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/decorations/$name.svg',
      width: width,
      placeholderBuilder: (context) => SizedBox(width: width),
    );
  }
}
