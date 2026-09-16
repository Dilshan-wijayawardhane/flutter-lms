/// Local-only model — sent to the backend when submitting a quiz.
class QuizSubmission {
  const QuizSubmission({
    required this.attemptId,
    required this.answers,
  });

  final String attemptId;

  /// Map of questionId → selected option index.
  final Map<String, int> answers;

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.entries
          .map((e) => {
        'questionId': e.key,
        'selectedOption': e.value,
      })
          .toList(),
    };
  }
}

class QuizStartResponse {
  const QuizStartResponse({
    required this.attemptId,
    required this.startedAt,
    this.quizId,
  });

  final String attemptId;
  final DateTime startedAt;
  final String? quizId;

  factory QuizStartResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return QuizStartResponse(
      attemptId: (data['attemptId'] ??
          data['id'] ??
          data['attempt']?['id'] ??
          '')
          .toString(),
      startedAt: _parseDate(data['startedAt']) ?? DateTime.now(),
      quizId: (data['quizId'] ?? data['quiz']?['id'])?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}