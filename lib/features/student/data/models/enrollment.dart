enum EnrollmentStatus { active, cancelled, completed }

class Enrollment {
  const Enrollment({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.studentId,
    required this.status,
    required this.progressPercent,
    this.courseThumbnailUrl,
    this.instructorName,
    this.enrolledAt,
    this.lastAccessedAt,
    this.completedLessonCount = 0,
    this.totalLessonCount = 0,
  });

  final String id;
  final String courseId;
  final String courseName;
  final String studentId;
  final EnrollmentStatus status;
  final int progressPercent;
  final String? courseThumbnailUrl;
  final String? instructorName;
  final DateTime? enrolledAt;
  final DateTime? lastAccessedAt;
  final int completedLessonCount;
  final int totalLessonCount;

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final courseJson = data['course'] as Map<String, dynamic>?;
    final instructorJson =
    courseJson?['instructor'] as Map<String, dynamic>?;

    final statusStr =
    ((data['status'] ?? 'ACTIVE') as String).toUpperCase();

    return Enrollment(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      courseId: (data['courseId'] ??
          courseJson?['id'] ??
          courseJson?['_id'] ??
          '')
          .toString(),
      courseName: (data['courseName'] ??
          courseJson?['title'] ??
          '')
          .toString(),
      studentId:
      (data['studentId'] ?? data['student']?['id'] ?? '').toString(),
      status: EnrollmentStatus.values.firstWhere(
            (s) => s.name.toUpperCase() == statusStr,
        orElse: () => EnrollmentStatus.active,
      ),
      progressPercent:
      (data['progressPercent'] as num?)?.toInt() ?? 0,
      courseThumbnailUrl:
      (courseJson?['thumbnailUrl'])?.toString(),
      instructorName: (instructorJson?['fullName'] ??
          instructorJson?['name'])
          ?.toString(),
      enrolledAt: _parseDate(data['enrolledAt'] ?? data['createdAt']),
      lastAccessedAt: _parseDate(data['lastAccessedAt']),
      completedLessonCount:
      (data['completedLessonCount'] as num?)?.toInt() ?? 0,
      totalLessonCount:
      (data['totalLessonCount'] as num?)?.toInt() ?? 0,
    );
  }

  String? get studentName => null;

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}