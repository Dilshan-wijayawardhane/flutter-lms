class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.attemptNumber,
    this.score,
    this.totalPoints,
    this.passed,
    this.startedAt,
    this.submittedAt,
    this.durationSeconds = 0,
  });

  final String id;
  final String quizId;
  final String quizTitle;
  final int attemptNumber;
  final int? score;
  final int? totalPoints;
  final bool? passed;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int durationSeconds;

  double? get scorePercent {
    if (score == null || totalPoints == null || totalPoints == 0) {
      return null;
    }
    return (score! / totalPoints!) * 100;
  }

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final quizJson = data['quiz'] as Map<String, dynamic>?;

    return QuizAttempt(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      quizId: (data['quizId'] ?? quizJson?['id'] ?? '').toString(),
      quizTitle:
      (data['quizTitle'] ?? quizJson?['title'] ?? '').toString(),
      attemptNumber: (data['attemptNumber'] as num?)?.toInt() ?? 1,
      score: (data['score'] as num?)?.toInt(),
      totalPoints: (data['totalPoints'] as num?)?.toInt(),
      passed: data['passed'] is bool ? data['passed'] as bool : null,
      startedAt: _parseDate(data['startedAt']),
      submittedAt: _parseDate(data['submittedAt']),
      durationSeconds:
      (data['durationSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}