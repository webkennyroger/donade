import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/animations/fade_slide_in.dart';
import '../../../shared/animations/fall_and_settle.dart';
import '../../../shared/widgets/ink_shadow.dart';
import '../../../shared/widgets/slide_to_start.dart';
import '../../quiz/data/mock_questions.dart';

const _decor = 'assets/images/decorations';
const _donade = 'assets/images/donade';

/// Tela de abertura do app: cartaz estilo "quadrinho" com o cartão do
/// desafio, a Dona Dê e o balão de fala, terminando no slider para começar.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with RouteAware {
  /// Muda a cada vez que esta tela volta a ficar visível, forçando o
  /// SlideToStart a ser recriado do zero (sem isso, ele ficaria preso no
  /// estado "concluído" da última vez que o usuário arrastou).
  int _resetKey = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => setState(() => _resetKey++);

  @override
  void didPopNext() => setState(() => _resetKey++);

  void _onSlideComplete(BuildContext context) {
    context.push('/quiz/${mockQuestions.first.categoryId}');
  }

  /// Tamanho de referência do design (tela de celular): a altura cobre só
  /// até onde os elementos realmente terminam (mão da personagem em
  /// y=720) — sobrar altura aqui empurra tudo pra cima e encolhe o
  /// desenho quando o FittedBox escala para telas de tablet.
  static const _designWidth = 420.0;
  static const _designHeight = 726.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        // Em telas grandes, em vez de só centralizar numa faixa estreita
        // (o que deixa um vão vazio embaixo), o cartaz inteiro escala como
        // um poster até preencher a altura ou largura disponível.
        child: isTablet
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _designWidth,
                    height: _designHeight,
                    child: _buildPhoneBody(context, _designWidth),
                  ),
                ),
              )
            : _buildPhoneBody(context, screenWidth),
      ),
    );
  }

  /// Layout original em cartaz vertical, pensado para telas de celular:
  /// tudo posicionado de forma absoluta, empilhado de cima para baixo.
  Widget _buildPhoneBody(BuildContext context, double screenWidth) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Splash decorativo atrás do crachá, sangrando pela borda esquerda.
        Positioned(
          top: 30,
          left: -95,
          child: FallAndSettle(
            fallDuration: const Duration(milliseconds: 800),
            startAngle: -0.3,
            child: SvgPicture.asset('$_decor/elemento-splash.svg', width: 360),
          ),
        ),
        // Linhas decorativas no canto superior direito.
        Positioned(
          top: 85,
          right: 4,
          child: FallAndSettle(
            delay: const Duration(milliseconds: 150),
            startAngle: 0.25,
            child: SvgPicture.asset('$_decor/elemento-risco.svg', width: 70),
          ),
        ),
        // Crachá da Defensoria.
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(
            child: FadeSlideIn(
              child: SvgPicture.asset(
                '$_decor/logo_badge.svg',
                width: screenWidth * 0.52,
              ),
            ),
          ),
        ),
        // Cartão "Desafio da Dona Dê".
        Positioned(
          top: 90,
          left: 16,
          right: 16,
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: _ChallengeCard(
              resetKey: _resetKey,
              onSlideComplete: () => _onSlideComplete(context),
            ),
          ),
        ),
        // Mola decorativa, encostada no canto do card, acima do cabelo.
        Positioned(
          top: 382,
          left: -100,
          child: FallAndSettle(
            delay: const Duration(milliseconds: 250),
            startAngle: -0.5,
            child: SvgPicture.asset('$_decor/mola.svg', width: 108),
          ),
        ),
        // Círculo verde/preto + Dona Dê, encostada no canto esquerdo.
        Positioned(
          top: 320,
          left: -30,
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 150),
            child: SizedBox(
              width: 360,
              height: 400,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -80,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF005F27),
                        border: Border.all(color: AppColors.ink, width: 5),
                        boxShadow: inkShadow(),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    '$_donade/donade-mao-cruzada.svg',
                    height: 300,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Duas estrelas encostadas perto do card, não sobre ele.
        Positioned(
          top: 305,
          right: 30,
          child: FallAndSettle(
            delay: const Duration(milliseconds: 350),
            startAngle: 0.5,
            child: SvgPicture.asset('$_decor/elemento-estrela.svg', width: 30),
          ),
        ),
        Positioned(
          top: 328,
          right: 30,
          child: FallAndSettle(
            delay: const Duration(milliseconds: 420),
            startAngle: -0.4,
            child: SvgPicture.asset('$_decor/sparkle_small.svg', width: 14),
          ),
        ),
        // Balão de fala: caixa pequena, texto grande. Fica na frente do
        // círculo verde (por isso vem depois dele na pilha).
        Positioned(
          top: 350,
          right: 8,
          child: FallAndSettle(
            delay: const Duration(milliseconds: 300),
            startAngle: 0.2,
            child: _SpeechBubble(width: screenWidth * 0.44),
          ),
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.resetKey, required this.onSlideComplete});

  final int resetKey;
  final VoidCallback onSlideComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: inkShadow(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF005F27),
              border: Border(
                bottom: BorderSide(color: AppColors.ink, width: 2),
              ),
            ),
            child: const Text(
              'JOGO DE PERGUNTAS E RESPOSTAS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'DESAFIO DA',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    color: AppColors.ink,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'Dona Dê',
                  style: TextStyle(
                    fontFamily: 'Magic',
                    color: Color.fromARGB(255, 1, 156, 66),
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                SlideToStart(
                  key: ValueKey(resetKey),
                  label: 'DESLIZE PARA COMEÇAR',
                  onComplete: onSlideComplete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SvgPicture.asset('$_decor/speech_bubble.svg', width: width),
          Padding(
            padding: EdgeInsets.only(
              top: width * 0.10,
              left: width * 0.12,
              right: width * 0.12,
            ),
            child: const Text(
              'Responda \ne concorra \na prêmios!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                color: AppColors.ink,
                fontSize: 25,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
