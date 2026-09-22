import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_questions.dart';
import '../../data/question.dart';

class QuizState {
  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedIndex,
    this.answered = false,
    this.score = 0,
    this.isFinished = false,
  });

  final List<Question> questions;
  final int currentIndex;
  final int? selectedIndex;
  final bool answered;
  final int score;
  final bool isFinished;

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  double get progress => questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? selectedIndex,
    bool? answered,
    int? score,
    bool? isFinished,
    bool clearSelectedIndex = false,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedIndex: clearSelectedIndex ? null : (selectedIndex ?? this.selectedIndex),
      answered: answered ?? this.answered,
      score: score ?? this.score,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

const kPointsPerCorrectAnswer = 10;

class QuizController extends Notifier<QuizState> {
  @override
  QuizState build() => const QuizState();

  void start(String categoryId) {
    state = QuizState(questions: questionsForCategory(categoryId));
  }

  void selectAnswer(int optionIndex) {
    if (state.answered || state.isFinished) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = optionIndex == question.correctIndex;
    state = state.copyWith(
      selectedIndex: optionIndex,
      answered: true,
      score: isCorrect ? state.score + kPointsPerCorrectAnswer : state.score,
    );
  }

  void nextQuestion() {
    if (!state.answered) return;
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(isFinished: true);
      return;
    }
    state = state.copyWith(
      currentIndex: nextIndex,
      answered: false,
      clearSelectedIndex: true,
    );
  }
}

final quizControllerProvider = NotifierProvider<QuizController, QuizState>(
  QuizController.new,
);
