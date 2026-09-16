enum QuizStatus { draft, published }

class Quiz {
  const Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.status,
    this.description,
    this.durationMinutes = 20,
    this.passingScore = 60,
    this.maxAttempts = 3,
    this.questionCount = 0,
    this.totalPoints = 0,
    this.attemptCount = 0,
    this.bestScore,
    this.createdAt,
  });

  final String id;
  final String courseId;
  final String title;
  final QuizStatus status;
  final String? description;
  final int durationMinutes;
  final int passingScore;
  final int maxAttempts;
  final int questionCount;
  final int totalPoints;
  final int attemptCount;
  final int? bestScore;
  final DateTime? createdAt;

  bool get canAttempt => attemptCount < maxAttempts;

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final statusStr =
    ((data['status'] ?? 'DRAFT') as String).toUpperCase();

    return Quiz(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      courseId:
      (data['courseId'] ?? data['course']?['id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      status: QuizStatus.values.firstWhere(
            (s) => s.name.toUpperCase() == statusStr,
        orElse: () => QuizStatus.draft,
      ),
      description: data['description']?.toString(),
      durationMinutes:
      (data['durationMinutes'] as num?)?.toInt() ?? 20,
      passingScore: (data['passingScore'] as num?)?.toInt() ?? 60,
      maxAttempts: (data['maxAttempts'] as num?)?.toInt() ?? 3,
      questionCount: (data['questionCount'] as num?)?.toInt() ?? 0,
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      attemptCount: (data['attemptCount'] as num?)?.toInt() ?? 0,
      bestScore: (data['bestScore'] as num?)?.toInt(),
      createdAt: _parseDate(data['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}