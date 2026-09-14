class MockQuizAttempt {
  const MockQuizAttempt({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.studentId,
    required this.studentName,
    required this.attemptNumber,
    this.score,
    this.totalPoints,
    this.passed,
    this.submittedAt,
    this.durationSeconds = 0,
  });

  final String id;
  final String quizId;
  final String quizTitle;
  final String studentId;
  final String studentName;
  final int attemptNumber;
  final int? score;
  final int? totalPoints;
  final bool? passed;
  final DateTime? submittedAt;
  final int durationSeconds;

  double? get scorePercent {
    if (score == null || totalPoints == null || totalPoints == 0) return null;
    return (score! / totalPoints!) * 100;
  }

  MockQuizAttempt copyWith({
    int? score,
    int? totalPoints,
    bool? passed,
    DateTime? submittedAt,
    int? durationSeconds,
  }) {
    return MockQuizAttempt(
      id: id,
      quizId: quizId,
      quizTitle: quizTitle,
      studentId: studentId,
      studentName: studentName,
      attemptNumber: attemptNumber,
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
      passed: passed ?? this.passed,
      submittedAt: submittedAt ?? this.submittedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  factory MockQuizAttempt.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockQuizAttempt.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockQuizAttempt.toJson');
  }
}