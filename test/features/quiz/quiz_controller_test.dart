import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_dona_de/features/quiz/presentation/controllers/quiz_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('start carrega as perguntas da categoria e zera o estado', () {
    final controller = container.read(quizControllerProvider.notifier);
    controller.start('ciencias');

    final state = container.read(quizControllerProvider);
    expect(state.questions, isNotEmpty);
    expect(state.questions.every((q) => q.categoryId == 'ciencias'), isTrue);
    expect(state.currentIndex, 0);
    expect(state.score, 0);
    expect(state.answered, isFalse);
    expect(state.isFinished, isFalse);
  });

  test('selecionar a resposta correta soma pontos e marca como respondida', () {
    final controller = container.read(quizControllerProvider.notifier);
    controller.start('ciencias');
    final correctIndex = container.read(quizControllerProvider).currentQuestion!.correctIndex;

    controller.selectAnswer(correctIndex);

    final state = container.read(quizControllerProvider);
    expect(state.answered, isTrue);
    expect(state.selectedIndex, correctIndex);
    expect(state.score, kPointsPerCorrectAnswer);
  });

  test('selecionar a resposta errada não soma pontos', () {
    final controller = container.read(quizControllerProvider.notifier);
    controller.start('ciencias');
    final correctIndex = container.read(quizControllerProvider).currentQuestion!.correctIndex;
    final wrongIndex = (correctIndex + 1) % 4;

    controller.selectAnswer(wrongIndex);

    final state = container.read(quizControllerProvider);
    expect(state.answered, isTrue);
    expect(state.score, 0);
  });

  test('responder duas vezes a mesma pergunta não altera a pontuação', () {
    final controller = container.read(quizControllerProvider.notifier);
    controller.start('ciencias');
    final correctIndex = container.read(quizControllerProvider).currentQuestion!.correctIndex;

    controller.selectAnswer(correctIndex);
    controller.selectAnswer((correctIndex + 1) % 4);

    final state = container.read(quizControllerProvider);
    expect(state.score, kPointsPerCorrectAnswer);
  });

  test('nextQuestion avança para a próxima pergunta e libera nova resposta', () {
    final controller = container.read(quizControllerProvider.notifier);
    controller.start('ciencias');
    controller.selectAnswer(0);

    controller.nextQuestion();

    final state = container.read(quizControllerProvider);
    expect(state.currentIndex, 1);
    expect(state.answered, isFalse);
    expect(state.selectedIndex, isNull);
    expect(state.isFinished, isFalse);
  });

  test('nextQuestion na última pergunta marca o quiz como finalizado', () {
    final controller = container.read(quizControllerProvider.notifier);
    controller.start('ciencias');
    final total = container.read(quizControllerProvider).questions.length;

    for (var i = 0; i < total; i++) {
      controller.selectAnswer(0);
      controller.nextQuestion();
    }

    final state = container.read(quizControllerProvider);
    expect(state.isFinished, isTrue);
  });

  test('nextQuestion sem responder não avança', () {
    final controller = container.read(quizControllerProvider.notifier);
    controller.start('ciencias');

    controller.nextQuestion();

    final state = container.read(quizControllerProvider);
    expect(state.currentIndex, 0);
  });
}
