import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/animations/answer_feedback.dart';
import '../../../../shared/widgets/ink_shadow.dart';
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
const _cardExtraBottomSpace = 360.0;

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
              const SizedBox(height: AppDimensions.spaceLg),
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
          // Centraliza verticalmente quando o cartão é mais baixo que a
          // tela (tablets, perguntas curtas); ainda rola se for mais alto.
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (!state.answered)
                    // O splash de bolinhas atrás do cartão, que só aparece antes de
                    // responder. Ele é grande e fica parcialmente fora da tela.
                    Positioned(
                      bottom: -30,
                      left: -200,
                      child: SvgPicture.asset('$_decor/elemento-splash.svg', width: 200),
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
                    top: -10,
                    left: -10,
                    child: SvgPicture.asset('$_decor/circulos.svg', width: 44),
                  ),
                  // O número da pergunta fica no canto superior direito do cartão,
                  // mas fora do cartão, em cima da barra verde. A posição é
                  // ajustada para que o círculo fique centrado na barra verde.
                  Positioned(
                    top: -30,
                    right: -60,
                    child: QuestionNumberBadge(number: state.currentIndex + 1, size: 112),
                  ),
                  // A pequena vem primeiro (fica atrás); a maior vem depois
                  // (fica na frente, por cima), as duas do lado de fora do
                  // cartão, em diagonal a partir do círculo do número.
                  Positioned(
                    top: 140,
                    right: -50,
                    child: SvgPicture.asset('$_decor/sparkle_small.svg', width: 18),
                  ),
                  Positioned(
                    top: 100,
                    right: -50,
                    child: SvgPicture.asset('$_decor/elemento-estrela.svg', width: 34),
                  ),
                  if (state.answered)
                    Positioned(
                      bottom: -20,
                      left: -16,
                      child: ResultBadge(isCorrect: isCorrect),
                    ),
                  // Ancorada a partir do topo (não do fundo) de propósito:
                  // assim ela não se move quando o espaço vazio embaixo das
                  // opções (o padding do `_QuestionCard`) for ajustado.
                  Positioned(
                    top: 480,
                    right: -50,
                    child: SvgPicture.asset(
                      state.answered
                          ? (isCorrect ? '$_donade/donade-acertou.svg' : '$_donade/donade-errou.svg')
                          : '$_donade/donade-pensando.svg',
                      height: 280,
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
            // Padding não aceita valores negativos, então o "passar da
            // borda esquerda" é feito deslocando o desenho com Transform
            // (não afeta o layout) e alargando a caixa pra compensar, pra
            // a margem direita continuar exatamente nos 16px pedidos.
            child: Transform.translate(
              offset: const Offset(-20, 0),
              child: SizedBox(
                width: _cardWidth - 16 + 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < options.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spaceLg),
                        child: AnswerOption(
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
        ],
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({required this.score, required this.total});

  final int score;
  final int total;

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
                SvgPicture.asset('$_decor/trofeu.svg', height: 140),
                const SizedBox(height: AppDimensions.spaceLg),
                Text(
                  'Você fez $score pontos em $total perguntas',
                  style: const TextStyle(fontFamily: 'NotoSans', fontSize: 16, color: AppColors.ink),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceXl),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      side: const BorderSide(color: AppColors.ink, width: 2),
                    ),
                    minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
                  ),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                  child: const Text('Voltar para o início'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
