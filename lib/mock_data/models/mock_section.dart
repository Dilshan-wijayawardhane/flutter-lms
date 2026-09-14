class MockSection {
  const MockSection({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.order,
    this.lessonCount = 0,
  });

  final String id;
  final String courseId;
  final String title;
  final String? description;

  /// 1-based ordering. Backend will own this in Phase 2; local only for UI.
  final int order;
  final int lessonCount;

  MockSection copyWith({
    String? title,
    String? description,
    int? order,
    int? lessonCount,
  }) {
    return MockSection(
      id: id,
      courseId: courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      lessonCount: lessonCount ?? this.lessonCount,
    );
  }

  factory MockSection.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockSection.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockSection.toJson');
  }
}