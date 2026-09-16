/// Response from start/complete lesson + enrollment progress.
class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    this.enrollmentId,
    this.isCompleted = false,
    this.completedAt,
    this.courseProgressPercent = 0,
    this.completedLessonCount = 0,
    this.totalLessonCount = 0,
  });

  final String lessonId;
  final String? enrollmentId;
  final bool isCompleted;
  final DateTime? completedAt;
  final int courseProgressPercent;
  final int completedLessonCount;
  final int totalLessonCount;

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    DateTime? parse(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

    return LessonProgress(
      lessonId:
      (data['lessonId'] ?? data['lesson']?['id'] ?? '').toString(),
      enrollmentId: (data['enrollmentId'] ?? data['enrollment']?['id'])
          ?.toString(),
      isCompleted:
      data['isCompleted'] == true || data['completed'] == true,
      completedAt: parse(data['completedAt']),
      courseProgressPercent:
      (data['courseProgressPercent'] ??
          data['progressPercent'] ??
          data['progress'] ??
          0)
      as int,
      completedLessonCount:
      (data['completedLessonCount'] as num?)?.toInt() ?? 0,
      totalLessonCount:
      (data['totalLessonCount'] as num?)?.toInt() ?? 0,
    );
  }
}