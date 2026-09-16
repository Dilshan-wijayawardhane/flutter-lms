class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.quizId,
    required this.text,
    required this.order,
    required this.points,
    required this.options,
  });

  final String id;
  final String quizId;
  final String text;
  final int order;
  final int points;
  final List<String> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    final optionsRaw = data['options'];
    List<String> options = const [];
    if (optionsRaw is List) {
      options = optionsRaw.map((e) {
        if (e is String) return e;
        if (e is Map<String, dynamic>) {
          return (e['text'] ?? e['label'] ?? '').toString();
        }
        return e.toString();
      }).toList();
    }

    return QuizQuestion(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      quizId:
      (data['quizId'] ?? data['quiz']?['id'] ?? '').toString(),
      text: (data['text'] ?? data['question'] ?? '').toString(),
      order: (data['order'] as num?)?.toInt() ?? 1,
      points: (data['points'] as num?)?.toInt() ?? 1,
      options: options,
    );
  }
}