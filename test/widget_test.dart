import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_dona_de/app/app.dart';
import 'package:quiz_dona_de/app/router.dart';

/// A Onboarding e a tela de pergunta têm decorações com brilho/balanço em
/// loop infinito, então pumpAndSettle nunca "assentaria"; avançamos os
/// frames manualmente pelo tempo necessário em vez disso.
Future<void> _settle(WidgetTester tester, [Duration duration = const Duration(milliseconds: 1200)]) async {
  await tester.pump();
  await tester.pump(duration);
}

void main() {
  testWidgets('Onboarding mostra a chamada para começar o quiz', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuizDonaDeApp()));
    await _settle(tester);

    expect(find.textContaining('DESAFIO DA'), findsOneWidget);
    expect(find.text('DESLIZE PARA COMEÇAR'), findsOneWidget);
  });

  testWidgets('Arrastar o slide to start abre a tela de pergunta', (WidgetTester tester) async {
    // O GoRouter é um singleton compartilhado entre os testes deste arquivo;
    // garantimos que cada teste comece na Onboarding.
    router.go('/');
    await tester.pumpWidget(const ProviderScope(child: QuizDonaDeApp()));
    await _settle(tester);

    await tester.drag(find.byKey(const Key('slideToStartHandle')), const Offset(600, 0));
    await _settle(tester, const Duration(milliseconds: 600));

    expect(find.text('PERGUNTA'), findsOneWidget);
  });

  testWidgets('Sair do quiz e voltar reseta o slide to start', (WidgetTester tester) async {
    router.go('/');
    await tester.pumpWidget(const ProviderScope(child: QuizDonaDeApp()));
    await _settle(tester);

    await tester.drag(find.byKey(const Key('slideToStartHandle')), const Offset(600, 0));
    await _settle(tester, const Duration(milliseconds: 600));

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.tap(find.text('Sair'));
    await _settle(tester, const Duration(milliseconds: 400));

    expect(find.text('DESLIZE PARA COMEÇAR'), findsOneWidget);

    // Se o slider tivesse ficado presa no estado "concluído" anterior, um
    // novo arrastar não navegaria de novo.
    await tester.drag(find.byKey(const Key('slideToStartHandle')), const Offset(600, 0));
    await _settle(tester, const Duration(milliseconds: 600));

    expect(find.text('PERGUNTA'), findsOneWidget);
  });

  testWidgets('Responder certo mostra a tela cheia e avança para a próxima pergunta', (WidgetTester tester) async {
    router.go('/');
    await tester.pumpWidget(const ProviderScope(child: QuizDonaDeApp()));
    await _settle(tester);

    await tester.drag(find.byKey(const Key('slideToStartHandle')), const Offset(600, 0));
    await _settle(tester, const Duration(milliseconds: 600));

    // Primeira alternativa da pergunta 1 (De 90.000 a 100.000) é a correta.
    await tester.tap(find.text('De 90.000 a 100.000'));
    await tester.pump();

    // Passado o atraso de revelação, a tela cheia "VOCÊ ACERTOU!" aparece.
    await tester.pump(const Duration(milliseconds: 950));
    expect(find.text('VOCÊ\nACERTOU!'), findsOneWidget);

    // Passado o tempo da tela cheia, avança para a segunda pergunta.
    await _settle(tester, const Duration(seconds: 2));
    expect(find.text('VOCÊ\nACERTOU!'), findsNothing);
    expect(find.text('Qual é o sistema que está integrado à Dona Dê?'), findsOneWidget);
  });
}
