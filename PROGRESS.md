# Progresso — Quiz da Dona Dê

Notas de continuidade do projeto. Último commit: `d98c35e` (enviado pro GitHub).

## Estado atual

### Onboarding (`lib/features/onboarding/presentation/onboarding_page.dart`)
- Considerado **fechado/aprovado** — bate com a referência (cartão "Desafio da Dona Dê", mola, balão de fala, Dona Dê no círculo verde).
- Em telas largas (tablet), o cartaz inteiro escala como poster (`FittedBox` + canvas fixo `_designWidth`/`_designHeight`) pra preencher a tela sem sobrar espaço vazio.

### Tela de pergunta (`lib/features/quiz/presentation/pages/quiz_question_page.dart`)
- Reformulada nesta sessão pra bater com a referência (print do "PERGUNTA 1" com círculo grande na ponta do cartão, estrelas fora da borda, opções largas, Dona Dê embaixo).
- **Largura e altura do cartão são variáveis isoladas no topo do arquivo**, de propósito:
  ```dart
  const _cardWidth = 340.0;
  const _cardExtraBottomSpace = 400.0;
  ```
  Mude os dois livremente — os elementos do canto (círculo do número, estrelas, splash, Dona Dê) são ancorados via `right:`/`left:`/`top:` relativos à própria borda do cartão, então acompanham a largura/altura automaticamente, sem precisar recalcular nada.
- **Dona Dê é ancorada por `top:` (não `bottom:`)** — decisão de propósito pra ela não se mover quando `_cardExtraBottomSpace` mudar.
- Badge do número (`lib/features/quiz/presentation/widgets/question_number_badge.dart`): a fonte NotoSans só tem os pesos Regular/Bold cadastrados no `pubspec.yaml` — pedir `FontWeight.w900` no código **não engrossa nada**. O efeito "mais grosso" foi simulado desenhando um contorno (`Paint()..style = PaintingStyle.stroke`) atrás do texto do número.
- Estrelas (`elemento-estrela.svg` + `sparkle_small.svg`): posicionadas com `right:` negativo (fora da borda do cartão), a maior desenhada **depois** da pequena na `Stack` (fica na frente/por cima), formando um conjunto diagonal a partir do círculo do número.

## Como testar (Windows, sem Mac/iPad na mão)

```bash
flutter run -d chrome --web-browser-flag="--window-size=834,1194"
```
Isso abre uma janela do Chrome já no tamanho lógico do iPad Pro 11" (834×1194), com hot reload funcionando de verdade (diferente de servir uma build estática).

- Antes de relançar, sempre limpar processos travados:
  ```bash
  Get-Process dart,dartvm,dartaotruntime -ErrorAction SilentlyContinue | Stop-Process -Force
  ```
- **Cuidado**: ao automatizar a janela do Chrome via PowerShell/Win32 (mover, printar), sempre confirme que o `hwnd` pertence a um processo `chrome.exe` com título começando em "Quiz da Dona" **antes** de mexer nele — já aconteceu de pegar a janela errada (VS Code) por engano.
- Não há como mandar hot-reload (`r`) pro processo do `flutter run` já em background nesta sessão — cada ajuste exige reiniciar o `flutter run` (~20-30s).
- Pra chegar na tela de pergunta a partir do onboarding sem clicar manualmente, simula um "arrastar" do botão via `mouse_event` do Win32 (ver histórico da sessão pro script).

## Pendências / próximos passos

- Confirmar com o usuário se a tela de pergunta está definitivamente aprovada (últimas rodadas de ajuste fino: tamanho do círculo, estrelas, largura das opções).
- Telas ainda não revisadas nesta rodada: `_QuizResultView` (tela final de pontuação) e `FullScreenResult` (tela cheia de "Você acertou/errou").
- Testar o fluxo completo (responder pergunta → tela cheia → próxima pergunta) depois dos ajustes visuais, pra garantir que nada quebrou funcionalmente (`flutter test` está passando, mas vale conferir visualmente).
- Repositório remoto: `https://github.com/webkennyroger/donade` (branch `master`), o usuário também commita direto pelo VS Code às vezes — sempre checar `git status`/`git log` antes de assumir o estado dos arquivos.
