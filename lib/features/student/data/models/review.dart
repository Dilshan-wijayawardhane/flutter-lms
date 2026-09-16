class CourseReview {
  const CourseReview({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.studentId,
    required this.studentName,
    this.studentAvatarUrl,
    required this.rating,
    required this.comment,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String courseId;
  final String courseName;
  final String studentId;
  final String studentName;
  final String? studentAvatarUrl;
  final int rating;
  final String comment;
  final bool isVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final student = data['student'] as Map<String, dynamic>?;
    final course = data['course'] as Map<String, dynamic>?;

    return CourseReview(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      courseId: (data['courseId'] ?? course?['id'] ?? '').toString(),
      courseName:
      (data['courseName'] ?? course?['title'] ?? '').toString(),
      studentId:
      (data['studentId'] ?? student?['id'] ?? '').toString(),
      studentName: (data['studentName'] ??
          student?['fullName'] ??
          student?['name'] ??
          '')
          .toString(),
      studentAvatarUrl:
      (data['studentAvatarUrl'] ?? student?['profileImageUrl'])
          ?.toString(),
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: (data['comment'] ?? '').toString(),
      isVisible: data['isVisible'] != false,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}