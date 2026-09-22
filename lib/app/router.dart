import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/quiz/presentation/pages/quiz_question_page.dart';
import 'app.dart';

final router = GoRouter(
  initialLocation: '/',
  observers: [routeObserver],
  routes: [
    GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
    GoRoute(
      path: '/quiz/:categoryId',
      builder: (context, state) => QuizQuestionPage(categoryId: state.pathParameters['categoryId']!),
    ),
  ],
);
