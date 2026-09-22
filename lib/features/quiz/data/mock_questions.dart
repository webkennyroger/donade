import 'package:flutter/material.dart';
import 'question.dart';
import 'quiz_category.dart';

/// Dados mockados para o protótipo visual. Serão substituídos pela
/// integração com Supabase em uma etapa futura.
const mockCategories = [
  QuizCategory(
    id: 'ciencias',
    name: 'Ciências',
    description: 'Teste seus conhecimentos',
    icon: Icons.science_rounded,
  ),
  QuizCategory(
    id: 'historia',
    name: 'História',
    description: 'Fatos e curiosidades',
    icon: Icons.museum_rounded,
  ),
  QuizCategory(
    id: 'geografia',
    name: 'Geografia',
    description: 'Explore o mundo',
    icon: Icons.public_rounded,
  ),
];

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
    text: 'Qual é o estado físico da água a 0°C ao nível do mar?',
    options: ['Gasoso', 'Líquido', 'Sólido', 'Plasma'],
    correctIndex: 2,
    explanation: 'A 0°C, a água congela e se torna sólida (gelo).',
  ),
  Question(
    id: 'historia-1',
    categoryId: 'historia',
    text: 'Em que ano o Brasil foi descoberto pelos portugueses?',
    options: ['1500', '1822', '1808', '1600'],
    correctIndex: 0,
    explanation: 'Os portugueses chegaram ao Brasil em 1500.',
  ),
  Question(
    id: 'historia-2',
    categoryId: 'historia',
    text: 'Quem proclamou a independência do Brasil?',
    options: ['Tiradentes', 'D. Pedro I', 'D. João VI', 'Getúlio Vargas'],
    correctIndex: 1,
    explanation: 'D. Pedro I proclamou a independência em 1822.',
  ),
  Question(
    id: 'geografia-1',
    categoryId: 'geografia',
    text: 'Qual é o maior país do mundo em extensão territorial?',
    options: ['China', 'Estados Unidos', 'Brasil', 'Rússia'],
    correctIndex: 3,
    explanation: 'A Rússia é o maior país do mundo em área territorial.',
  ),
  Question(
    id: 'geografia-2',
    categoryId: 'geografia',
    text: 'Qual é o maior oceano do planeta?',
    options: ['Atlântico', 'Índico', 'Pacífico', 'Ártico'],
    correctIndex: 2,
    explanation: 'O Oceano Pacífico é o maior e mais profundo do mundo.',
  ),
];

List<Question> questionsForCategory(String categoryId) {
  return mockQuestions.where((q) => q.categoryId == categoryId).toList();
}
