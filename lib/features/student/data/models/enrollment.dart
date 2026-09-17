enum EnrollmentStatus { active, cancelled, completed }

class Enrollment {
  const Enrollment({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.studentId,
    required this.studentName,
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

  /// Never null — falls back to the studentId when the backend omits a name.
  final String studentName;

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
    final studentJson = data['student'] as Map<String, dynamic>?;
    final instructorJson =
    courseJson?['instructor'] as Map<String, dynamic>?;

    final statusStr =
    ((data['status'] ?? 'ACTIVE') as String).toUpperCase();

    final studentId =
    (data['studentId'] ?? studentJson?['id'] ?? studentJson?['_id'] ?? '')
        .toString();

    // Prefer an explicit name from the payload; otherwise derive from the
    // student object; otherwise fall back to the ID so the field is never
    // null and UI code can rely on it.
    final studentName = (data['studentName'] ??
        studentJson?['fullName'] ??
        studentJson?['name'] ??
        '')
        .toString();

    return Enrollment(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      courseId: (data['courseId'] ??
          courseJson?['id'] ??
          courseJson?['_id'] ??
          '')
          .toString(),
      courseName:
      (data['courseName'] ?? courseJson?['title'] ?? '').toString(),
      studentId: studentId,
      studentName: studentName.isNotEmpty ? studentName : studentId,
      status: EnrollmentStatus.values.firstWhere(
            (s) => s.name.toUpperCase() == statusStr,
        orElse: () => EnrollmentStatus.active,
      ),
      progressPercent:
      (data['progressPercent'] as num?)?.toInt() ?? 0,
      courseThumbnailUrl: courseJson?['thumbnailUrl']?.toString(),
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

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}