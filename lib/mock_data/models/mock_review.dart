enum ReviewVisibility {
  visible,
  hidden;

  String get wireValue {
    switch (this) {
      case ReviewVisibility.visible:
        return 'VISIBLE';
      case ReviewVisibility.hidden:
        return 'HIDDEN';
    }
  }

  String get label {
    switch (this) {
      case ReviewVisibility.visible:
        return 'Visible';
      case ReviewVisibility.hidden:
        return 'Hidden';
    }
  }
}

class MockReview {
  const MockReview({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.studentId,
    required this.studentName,
    this.studentAvatarUrl,
    required this.rating,
    required this.comment,
    required this.visibility,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String courseId;
  final String courseName;
  final String studentId;
  final String studentName;
  final String? studentAvatarUrl;
  final int rating; // 1..5
  final String comment;
  final ReviewVisibility visibility;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MockReview copyWith({
    int? rating,
    String? comment,
    ReviewVisibility? visibility,
  }) {
    return MockReview(
      id: id,
      courseId: courseId,
      courseName: courseName,
      studentId: studentId,
      studentName: studentName,
      studentAvatarUrl: studentAvatarUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory MockReview.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockReview.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockReview.toJson');
  }
}