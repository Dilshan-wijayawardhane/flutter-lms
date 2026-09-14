class MockQuizQuestion {
  const MockQuizQuestion({
    required this.id,
    required this.quizId,
    required this.text,
    required this.order,
    required this.points,
    required this.options,
    this.correctOptionIndex,
  });

  final String id;
  final String quizId;
  final String text;
  final int order;
  final int points;
  final List<String> options;

  /// Only used for mock answer preview. Authoritative correctness comes
  /// from the backend in Phase 2 and never from the client.
  final int? correctOptionIndex;

  MockQuizQuestion copyWith({
    String? text,
    int? order,
    int? points,
    List<String>? options,
    int? correctOptionIndex,
  }) {
    return MockQuizQuestion(
      id: id,
      quizId: quizId,
      text: text ?? this.text,
      order: order ?? this.order,
      points: points ?? this.points,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
    );
  }

  factory MockQuizQuestion.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockQuizQuestion.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockQuizQuestion.toJson');
  }
}