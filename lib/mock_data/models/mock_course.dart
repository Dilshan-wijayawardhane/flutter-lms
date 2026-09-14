/// Course status — matches backend values.
enum CourseStatus {
  draft,
  published,
  archived;

  String get wireValue {
    switch (this) {
      case CourseStatus.draft:
        return 'DRAFT';
      case CourseStatus.published:
        return 'PUBLISHED';
      case CourseStatus.archived:
        return 'ARCHIVED';
    }
  }

  String get label {
    switch (this) {
      case CourseStatus.draft:
        return 'Draft';
      case CourseStatus.published:
        return 'Published';
      case CourseStatus.archived:
        return 'Archived';
    }
  }
}

/// Course level.
enum CourseLevel {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case CourseLevel.beginner:
        return 'Beginner';
      case CourseLevel.intermediate:
        return 'Intermediate';
      case CourseLevel.advanced:
        return 'Advanced';
    }
  }
}

class MockCourse {
  const MockCourse({
    required this.id,
    required this.title,
    required this.instructorId,
    required this.instructorName,
    required this.categoryId,
    required this.categoryName,
    required this.status,
    required this.level,
    required this.description,
    this.shortDescription,
    this.thumbnailUrl,
    this.price = 0,
    this.rating = 0,
    this.ratingCount = 0,
    this.learnerCount = 0,
    this.sectionCount = 0,
    this.lessonCount = 0,
    this.totalDurationMinutes = 0,
    this.isEnrolled = false,
    this.progressPercent = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String instructorId;
  final String instructorName;
  final String categoryId;
  final String categoryName;
  final CourseStatus status;
  final CourseLevel level;
  final String description;
  final String? shortDescription;
  final String? thumbnailUrl;
  final double price;
  final double rating;
  final int ratingCount;
  final int learnerCount;
  final int sectionCount;
  final int lessonCount;
  final int totalDurationMinutes;
  final bool isEnrolled;
  final int progressPercent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MockCourse copyWith({
    String? title,
    String? description,
    String? shortDescription,
    CourseStatus? status,
    CourseLevel? level,
    String? categoryId,
    String? categoryName,
    String? thumbnailUrl,
    double? price,
    bool? isEnrolled,
    int? progressPercent,
  }) {
    return MockCourse(
      id: id,
      title: title ?? this.title,
      instructorId: instructorId,
      instructorName: instructorName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      status: status ?? this.status,
      level: level ?? this.level,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      price: price ?? this.price,
      rating: rating,
      ratingCount: ratingCount,
      learnerCount: learnerCount,
      sectionCount: sectionCount,
      lessonCount: lessonCount,
      totalDurationMinutes: totalDurationMinutes,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      progressPercent: progressPercent ?? this.progressPercent,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory MockCourse.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockCourse.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockCourse.toJson');
  }
}