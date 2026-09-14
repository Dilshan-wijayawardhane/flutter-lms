enum QuizStatus {
  draft,
  published;

  String get wireValue {
    switch (this) {
      case QuizStatus.draft:
        return 'DRAFT';
      case QuizStatus.published:
        return 'PUBLISHED';
    }
  }

  String get label {
    switch (this) {
      case QuizStatus.draft:
        return 'Draft';
      case QuizStatus.published:
        return 'Published';
    }
  }
}

class MockQuiz {
  const MockQuiz({
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
  final DateTime? createdAt;

  MockQuiz copyWith({
    String? title,
    String? description,
    QuizStatus? status,
    int? durationMinutes,
    int? passingScore,
    int? maxAttempts,
    int? questionCount,
    int? totalPoints,
  }) {
    return MockQuiz(
      id: id,
      courseId: courseId,
      title: title ?? this.title,
      status: status ?? this.status,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      passingScore: passingScore ?? this.passingScore,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      questionCount: questionCount ?? this.questionCount,
      totalPoints: totalPoints ?? this.totalPoints,
      createdAt: createdAt,
    );
  }

  factory MockQuiz.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockQuiz.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockQuiz.toJson');
  }
}