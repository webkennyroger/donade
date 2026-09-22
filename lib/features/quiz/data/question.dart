class Question {
  const Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.imageAsset,
  });

  final String id;
  final String categoryId;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  /// Caminho da imagem ilustrativa da pergunta. Quando nulo, a tela mostra
  /// um ícone de placeholder da categoria em vez da imagem.
  final String? imageAsset;
}
