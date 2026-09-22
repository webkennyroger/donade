import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icon.dart';

/// Trilha com um círculo arrastável até o fim para confirmar uma ação,
/// estilo "slide to start". Volta para o início se soltar antes do limite.
class SlideToStart extends StatefulWidget {
  const SlideToStart({super.key, required this.label, required this.onComplete});

  final String label;
  final VoidCallback onComplete;

  static const _handleSize = 52.0;
  static const _completeThreshold = 0.8;

  @override
  State<SlideToStart> createState() => _SlideToStartState();
}

class _SlideToStartState extends State<SlideToStart> with SingleTickerProviderStateMixin {
  double _dragX = 0;
  bool _completed = false;

  double _maxDrag(double trackWidth) => trackWidth - SlideToStart._handleSize;

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (_completed) return;
    setState(() {
      _dragX = (_dragX + details.delta.dx).clamp(0, _maxDrag(trackWidth));
    });
  }

  void _onDragEnd(double trackWidth) {
    if (_completed) return;
    final maxDrag = _maxDrag(trackWidth);
    final progress = maxDrag == 0 ? 0 : _dragX / maxDrag;
    if (progress >= SlideToStart._completeThreshold) {
      setState(() {
        _completed = true;
        _dragX = maxDrag;
      });
      widget.onComplete();
    } else {
      setState(() => _dragX = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final maxDrag = _maxDrag(trackWidth);
        final progress = maxDrag == 0 ? 0.0 : _dragX / maxDrag;

        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            border: Border.all(color: const Color(0xFF1D1D1B)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Preenchimento de progresso: só aparece depois que o usuário
              // começa a arrastar (em repouso não deve mostrar nada verde).
              if (_dragX > 0)
                AnimatedContainer(
                  duration: _completed ? const Duration(milliseconds: 250) : Duration.zero,
                  width: _dragX + SlideToStart._handleSize,
                  height: 64,
                  color: AppColors.primaryLight,
                ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: SlideToStart._handleSize, right: 16),
                  child: Opacity(
                    opacity: (1 - progress).clamp(0.0, 1.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(widget.label, style: AppTextStyles.button.copyWith(color: AppColors.textPrimary)),
                          ),
                        ),
                        const AppIcon(name: 'chevrons_right', size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _completed ? const Duration(milliseconds: 250) : Duration.zero,
                left: _dragX,
                child: GestureDetector(
                  key: const Key('slideToStartHandle'),
                  onHorizontalDragUpdate: (details) => _onDragUpdate(details, trackWidth),
                  onHorizontalDragEnd: (_) => _onDragEnd(trackWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: AppIcon(name: 'arrow_right', size: SlideToStart._handleSize - 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
