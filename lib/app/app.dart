import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

/// Observador global de rotas. Telas que precisam resetar seu estado quando
/// voltam a ficar visíveis (ex.: a Onboarding após saído do quiz) usam
/// [RouteAware] com este observer.
final routeObserver = RouteObserver<PageRoute<void>>();

class QuizDonaDeApp extends StatelessWidget {
  const QuizDonaDeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Quiz da Dona Dê',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
