enum EnrollmentStatus {
  active,
  cancelled,
  completed;

  String get wireValue {
    switch (this) {
      case EnrollmentStatus.active:
        return 'ACTIVE';
      case EnrollmentStatus.cancelled:
        return 'CANCELLED';
      case EnrollmentStatus.completed:
        return 'COMPLETED';
    }
  }

  String get label {
    switch (this) {
      case EnrollmentStatus.active:
        return 'Active';
      case EnrollmentStatus.cancelled:
        return 'Cancelled';
      case EnrollmentStatus.completed:
        return 'Completed';
    }
  }
}

class MockEnrollment {
  const MockEnrollment({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseThumbnailUrl,
    required this.instructorName,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.progressPercent,
    this.enrolledAt,
    this.lastAccessedAt,
    this.completedLessonCount = 0,
    this.totalLessonCount = 0,
  });

  final String id;
  final String courseId;
  final String courseName;
  final String? courseThumbnailUrl;
  final String instructorName;
  final String studentId;
  final String studentName;
  final EnrollmentStatus status;
  final int progressPercent;
  final DateTime? enrolledAt;
  final DateTime? lastAccessedAt;
  final int completedLessonCount;
  final int totalLessonCount;

  MockEnrollment copyWith({
    EnrollmentStatus? status,
    int? progressPercent,
    int? completedLessonCount,
    int? totalLessonCount,
    DateTime? lastAccessedAt,
  }) {
    return MockEnrollment(
      id: id,
      courseId: courseId,
      courseName: courseName,
      courseThumbnailUrl: courseThumbnailUrl,
      instructorName: instructorName,
      studentId: studentId,
      studentName: studentName,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      enrolledAt: enrolledAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      completedLessonCount:
      completedLessonCount ?? this.completedLessonCount,
      totalLessonCount: totalLessonCount ?? this.totalLessonCount,
    );
  }

  factory MockEnrollment.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockEnrollment.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockEnrollment.toJson');
  }
}