import 'question.dart';

/// Dados mockados para o protótipo visual. Serão substituídos pela
/// integração com Supabase em uma etapa futura.
const mockQuestions = <Question>[
  Question(
    id: 'ciencias-0',
    categoryId: 'ciencias',
    text: 'Quantos atendimentos mensais são realizados pela DPEMT via WhatsApp?',
    options: ['De 90.000 a 100.000', 'De 25.000 a 50.000', 'De 7.000 a 15.000'],
    correctIndex: 0,
    explanation: 'A DPEMT realiza entre 90.000 e 100.000 atendimentos mensais via WhatsApp.',
  ),
  Question(
    id: 'ciencias-1',
    categoryId: 'ciencias',
    text: 'Qual é o sistema que está integrado à Dona Dê?',
    options: ['PJE', 'SOLAR', 'EPROC'],
    correctIndex: 1,
    explanation: 'A Dona Dê está integrada ao sistema SOLAR.',
  ),
  Question(
    id: 'ciencias-2',
    categoryId: 'ciencias',
    text: 'Que horas posso falar com a Dona Dê?',
    options: ['Qualquer horário', '8h às 18h', '12h às 18h'],
    correctIndex: 0,
    explanation: 'A Dona Dê atende em qualquer horário. O atendimento humano é das 12h às 18h de segunda a sexta-feira',
  ),
];

List<Question> questionsForCategory(String categoryId) {
  return mockQuestions.where((q) => q.categoryId == categoryId).toList();
}
