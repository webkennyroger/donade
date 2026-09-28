import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/animations/answer_feedback.dart';
import '../../../../shared/widgets/ink_shadow.dart';
import '../../../../shared/widgets/trophy_animation.dart';
import '../../data/question.dart';
import '../controllers/quiz_controller.dart';
import '../widgets/answer_option.dart';
import '../widgets/full_screen_result.dart';
import '../widgets/question_number_badge.dart';
import '../widgets/result_badge.dart';

const _decor = 'assets/images/decorations';
const _donade = 'assets/images/donade';

// Largura e altura do cartão, isoladas de propósito: mude os dois valores
// livremente, sem afetar mais nada. Isso funciona porque:
// - Largura: os elementos do canto (círculo, estrelas, splash, Dona Dê) são
//   ancorados via `right:`/`left:` relativos à própria borda do cartão,
//   então acompanham a largura automaticamente.
// - Altura: a Dona Dê é ancorada via `top:` (não `bottom:`), então não se
//   move quando `_cardExtraBottomSpace` muda.
const _cardWidth = 340.0;
const _cardExtraBottomSpace = 340.0;

// Quanto a pílula de resposta "vaza" pra fora de cada lado do cartão.
// Zero = não vaza (fica só até a borda). Cada um é independente do outro.
// Isso só muda o TAMANHO da pílula, não a posição.
const _pillLeftBleed = 10.0;
const _pillRightBleed = 80.0;

// Move a pílula sem mudar o tamanho dela: positivo desce/vai pra direita,
// negativo sobe/vai pra esquerda.
const _pillOffsetX = 20.0;
const _pillOffsetY = 0.0;

// Espaço entre o cabeçalho ("DESAFIO DA Dona Dê") e o cartão/bolha do
// número, embaixo. Isolado do resto (não usa `AppDimensions.spaceLg`) pra
// poder aumentar sem afetar o espaçamento de mais nada na tela.
const _headerToCardGap = 48.0;

// Número máximo de alternativas entre todas as perguntas (a maioria tem 4;
// só duas têm 3). O cartão sempre reserva espaço para esse máximo — nas
// perguntas com menos alternativas, o espaço restante fica em branco (ver
// `_QuestionCard`) — assim a base (cabeçalho, cartão, Dona Dê) fica
// IDÊNTICA em todas as perguntas; só o texto muda.
const _maxOptionsPerQuestion = 3;

// Posição fixa da Dona Dê. Como o cartão sempre tem a altura calibrada
// para `_maxOptionsPerQuestion`, esse valor não precisa mudar por pergunta.
const _donadeTop = 600.0;

// Todos os tamanhos/posições horizontais dos elementos decorativos abaixo
// foram calibrados visualmente com `_cardWidth` em 340 (a "largura de
// referência"). Em vez de escrever pixels fixos, cada valor é
// `pixelCalibrado / _referenceWidth * _cardWidth` — assim, se `_cardWidth`
// mudar, tudo escala junto, em vez de ficar desproporcional. (Técnica
// emprestada de um protótipo que posicionava elementos como fração de um
// canvas de referência, em vez de pixel fixo.)
const _referenceWidth = 340.0;
double _scaled(double pixelAtReferenceWidth) => pixelAtReferenceWidth / _referenceWidth * _cardWidth;

/// Quanto tempo o cartão fica com a alternativa colorida antes da tela
/// cheia de "Você acertou/errou" aparecer, e por quanto tempo ela fica.
const _kRevealDelay = Duration(milliseconds: 900);
const _kFullScreenDuration = Duration(seconds: 2);

class QuizQuestionPage extends ConsumerStatefulWidget {
  const QuizQuestionPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends ConsumerState<QuizQuestionPage> {
  bool _showFullScreenResult = false;
  Timer? _revealTimer;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizControllerProvider.notifier).start(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _onAnswered() {
    _revealTimer = Timer(_kRevealDelay, () {
      if (!mounted) return;
      setState(() => _showFullScreenResult = true);
      _advanceTimer = Timer(_kFullScreenDuration, () {
        if (!mounted) return;
        setState(() => _showFullScreenResult = false);
        ref.read(quizControllerProvider.notifier).nextQuestion();
      });
    });
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do quiz?'),
        content: const Text('Seu progresso nesta pergunta será perdido.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
        ],
      ),
    );
    if (shouldExit == true && mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(quizControllerProvider, (previous, next) {
      if (previous?.answered == false && next.answered == true) {
        _onAnswered();
      }
    });

    final state = ref.watch(quizControllerProvider);

    if (state.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFEDEDED),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (state.isFinished) {
      return _QuizResultView(score: state.score, total: state.questions.length);
    }

    if (_showFullScreenResult) {
      final question = state.currentQuestion!;
      return FullScreenResult(isCorrect: state.selectedIndex == question.correctIndex);
    }

    final question = state.currentQuestion!;
    final isCorrect = state.answered && state.selectedIndex == question.correctIndex;
    final isTablet = MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: state.answered
          ? (isCorrect ? const Color(0xFFDCF3E3) : const Color(0xFFFBDEDE))
          : const Color(0xFFEDEDED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onBack: _confirmExit),
              const SizedBox(height: _headerToCardGap),
              Expanded(
                // Em telas largas, mantemos o mesmo cartão de celular,
                // só centralizado, em vez de reorganizar o conteúdo.
                child: isTablet
                    ? Center(
                        child: SizedBox(
                          width: _cardWidth,
                          child: _buildPhoneBody(state, question, isCorrect),
                        ),
                      )
                    : _buildPhoneBody(state, question, isCorrect),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneBody(QuizState state, Question question, bool isCorrect) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // `clipBehavior: Clip.none` é essencial em modo tablet: lá em cima
          // o cartão fica dentro de um SizedBox estreito (`_cardWidth`), e
          // por padrão essa área de rolagem recorta tudo que passa dessa
          // largura — cortando a bolha do número, as estrelas, a pílula que
          // vaza e a Dona Dê bem na borda do cartão.
          clipBehavior: Clip.none,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            // Alinhado no TOPO (não centralizado) de propósito: perguntas
            // com 4 opções deixam o cartão mais alto que perguntas com 3.
            // Se centralizasse verticalmente, esse cartão mais alto
            // "empurraria" o topo (cabeçalho, bolha do número, estrelas)
            // pra uma posição diferente em cada pergunta. Alinhando no
            // topo, o cabeçalho sempre começa no mesmo lugar; só a base
            // (opções + Dona Dê) varia, e a tela rola se precisar.
            child: Align(
              alignment: Alignment.topCenter,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (!state.answered)
                    // O splash de bolinhas atrás do cartão, que só aparece antes de
                    // responder. Ele é grande e fica parcialmente fora da tela.
                    Positioned(
                      bottom: _scaled(-30),
                      left: _scaled(-80),
                      child: SvgPicture.asset('$_decor/elemento-splash.svg', width: _scaled(200)),
                    ),
                    // O cartão da pergunta, com o número da pergunta e as opções.
                  _QuestionCard(
                    text: question.text,
                    options: question.options,
                    correctIndex: question.correctIndex,
                    selectedIndex: state.selectedIndex,
                    answered: state.answered,
                    onSelect: (index) => ref.read(quizControllerProvider.notifier).selectAnswer(index),
                  ),
                  // Padrão de bolinhas saindo do canto superior esquerdo do
                  // cartão, atrás da barra verde.
                  Positioned(
                    top: _scaled(-10),
                    left: _scaled(-10),
                    child: SvgPicture.asset('$_decor/circulos.svg', width: _scaled(44)),
                  ),
                  // O número da pergunta fica no canto superior direito do cartão,
                  // mas fora do cartão, em cima da barra verde. A posição é
                  // ajustada para que o círculo fique centrado na barra verde.
                  Positioned(
                    top: _scaled(-30),
                    right: _scaled(-60),
                    child: QuestionNumberBadge(number: state.currentIndex + 1, size: _scaled(112)),
                  ),
                  // A pequena vem primeiro (fica atrás); a maior vem depois
                  // (fica na frente, por cima), as duas do lado de fora do
                  // cartão, em diagonal a partir do círculo do número.
                  Positioned(
                    top: _scaled(130),
                    right: _scaled(-80),
                    child: SvgPicture.asset('$_decor/sparkle_small.svg', width: _scaled(28)),
                  ),
                  Positioned(
                    top: _scaled(85),
                    right: _scaled(-70),
                    child: SvgPicture.asset('$_decor/elemento-estrela.svg', width: _scaled(52)),
                  ),
                  if (state.answered)
                    Positioned(
                      bottom: _scaled(30),
                      left: _scaled(20),
                      child: ResultBadge(isCorrect: isCorrect),
                    ),
                  // Ancorada a partir do topo (não do fundo) de propósito: assim
                  // ela não se move quando o espaço vazio embaixo das opções (o
                  // padding do `_QuestionCard`) for ajustado. O `top` fica em
                  // pixel fixo (não escala com a largura) porque depende da
                  // altura do texto da pergunta, não da largura do cartão.
                  // Pode ficar fixo porque o cartão sempre reserva espaço para
                  // `_maxOptionsPerQuestion` alternativas (ver `_QuestionCard`).
                  Positioned(
                    top: _donadeTop,
                    right: _scaled(-180),
                    child: SvgPicture.asset(
                      state.answered
                          ? (isCorrect ? '$_donade/donade-acertou.svg' : '$_donade/donade-errou.svg')
                          : '$_donade/donade-pensando.svg',
                      height: _scaled(780),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: AppColors.ink),
            ),
            const SizedBox(width: AppDimensions.spaceXs),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.ink),
                children: [
                  TextSpan(text: 'DESAFIO DA\n'),
                  TextSpan(
                    text: 'Dona Dê',
                    style: TextStyle(fontFamily: 'Magic', fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF005F27)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SvgPicture.asset('$_decor/logo_badge.svg', width: 150),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        Container(height: 2, color: AppColors.ink),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
    required this.answered,
    required this.onSelect,
  });

  final String text;
  final List<String> options;
  final int correctIndex;
  final int? selectedIndex;
  final bool answered;
  final ValueChanged<int> onSelect;

  AnswerState _stateFor(int index) {
    if (!answered) return AnswerState.idle;
    if (index == correctIndex) return AnswerState.correct;
    if (index == selectedIndex) return AnswerState.incorrect;
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: inkShadow(),
      ),
      // Sem recorte: as opções (mais abaixo) precisam poder passar da
      // borda esquerda do cartão. O cabeçalho ganha o mesmo raio de canto
      // do cartão pra continuar parecendo arredondado mesmo sem o recorte.
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 122, 14),
            decoration: const BoxDecoration(
              color: Color(0xFF005F27),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
              border: Border(bottom: BorderSide(color: AppColors.ink, width: 2)),
            ),
            child: const Text(
              'PERGUNTA',
              style: TextStyle(
                fontFamily: 'NotoSans',
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                
              ),
            ),
          ),
          // O texto da pergunta, com padding maior em cima e menor embaixo, para
          // que o espaço embaixo seja ajustado dinamicamente para que a parte de
          // baixo do cartão (as opções) fique sempre na mesma posição, mesmo que
          // o texto da pergunta seja curto ou longo.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 17,
                color: AppColors.ink,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXl),
          // O padding embaixo é grande para que o espaço vazio embaixo das opções
          // seja ajustado dinamicamente, de acordo com o tamanho do texto da
          // pergunta, para que a parte de baixo do cartão (as opções) fique sempre
          // na mesma posição, mesmo que o texto da pergunta seja curto ou longo.
          Padding(
            padding: const EdgeInsets.only(bottom: _cardExtraBottomSpace),
            // O cartão usa `CrossAxisAlignment.stretch`, que trava a largura
            // de qualquer filho na largura do cartão — um SizedBox mais
            // largo aqui dentro seria cortado de volta, sem aviso nenhum.
            // `OverflowBox` deixa o filho ser maior sem cortar E sem gerar
            // aviso de "overflow" (é literalmente pra isso que ele existe).
            // `IntrinsicHeight` só está aqui porque estamos dentro de uma
            // área de rolagem (altura "infinita" disponível) — sem ele, o
            // OverflowBox não sabe qual altura usar. `alignment: centerLeft`
            // mantém a borda esquerda no lugar (posição não muda) e deixa o
            // excesso vazar só pra direita.
            // Transform.translate só desloca o desenho na tela — não muda
            // nenhum tamanho, nenhuma largura, nada de layout. É só isso
            // que controla `_pillOffsetX`/`_pillOffsetY`.
            child: Transform.translate(
              offset: Offset(_scaled(_pillOffsetX), _pillOffsetY),
              child: IntrinsicHeight(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  maxWidth: _cardWidth + _scaled(_pillLeftBleed) + _scaled(_pillRightBleed),
                  child: SizedBox(
                    width: _cardWidth + _scaled(_pillLeftBleed) + _scaled(_pillRightBleed),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Vai até `_maxOptionsPerQuestion`, não só até
                        // `options.length`: perguntas com menos alternativas
                        // (3, em vez de 4) preenchem o restante com um
                        // espaço invisível do mesmo tamanho de uma opção
                        // real (via `Opacity`+`IgnorePointer`, não um
                        // número de pixels chutado), pra o cartão ter
                        // sempre a mesma altura, e a Dona Dê poder usar uma
                        // posição fixa em qualquer pergunta.
                        for (var index = 0; index < _maxOptionsPerQuestion; index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.spaceLg),
                            child: index >= options.length
                                ? IgnorePointer(
                                    child: Opacity(
                                      opacity: 0,
                                      child: AnswerOption(
                                        label: '',
                                        optionLetter: '',
                                        state: AnswerState.idle,
                                        onTap: () {},
                                      ),
                                    ),
                                  )
                                : AnswerOption(
                              label: options[index],
                              optionLetter: String.fromCharCode(65 + index),
                              state: _stateFor(index),
                              onTap: () => onSelect(index),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({required this.score, required this.total});

  final int score;
  final int total;

  // Tamanho do troféu animado (raios, confete e brilhos escalam com ele).
  // O botão embaixo usa essa mesma largura, em vez do padrão esticado, pra
  // ficar do tamanho do conteúdo do troféu.
  static const _trophySize = 420.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TrophyAnimation(size: _trophySize),
                const SizedBox(height: AppDimensions.spaceLg),
                Text(
                  'VOCÊ FEZ $score PONTOS EM $total PERGUNTAS',
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 24,

                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceXl),
                SizedBox(
                  width: _trophySize,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                        side: const BorderSide(color: AppColors.ink, width: 2),
                      ),
                    ),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                    child: const Text('Voltar para o início'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
