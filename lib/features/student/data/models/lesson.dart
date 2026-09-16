enum LessonType { text, video, document }

enum LessonStatus { draft, published }

class Lesson {
  const Lesson({
    required this.id,
    required this.sectionId,
    required this.courseId,
    required this.title,
    required this.type,
    required this.status,
    required this.order,
    this.durationMinutes = 0,
    this.content,
    this.videoUrl,
    this.documentUrl,
    this.documentName,
    this.isCompleted = false,
    this.isLocked = false,
  });

  final String id;
  final String sectionId;
  final String courseId;
  final String title;
  final LessonType type;
  final LessonStatus status;
  final int order;
  final int durationMinutes;
  final String? content;
  final String? videoUrl;
  final String? documentUrl;
  final String? documentName;
  final bool isCompleted;
  final bool isLocked;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    final typeStr =
    ((data['type'] ?? 'TEXT') as String).toUpperCase();
    final statusStr =
    ((data['status'] ?? 'DRAFT') as String).toUpperCase();

    return Lesson(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      sectionId: (data['sectionId'] ?? data['section']?['id'] ?? '')
          .toString(),
      courseId:
      (data['courseId'] ?? data['course']?['id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      type: LessonType.values.firstWhere(
            (t) => t.name.toUpperCase() == typeStr,
        orElse: () => LessonType.text,
      ),
      status: LessonStatus.values.firstWhere(
            (s) => s.name.toUpperCase() == statusStr,
        orElse: () => LessonStatus.draft,
      ),
      order: (data['order'] as num?)?.toInt() ?? 1,
      durationMinutes:
      (data['durationMinutes'] as num?)?.toInt() ?? 0,
      content: data['content']?.toString(),
      videoUrl: (data['videoUrl'] ?? data['video'])?.toString(),
      documentUrl:
      (data['documentUrl'] ?? data['document'])?.toString(),
      documentName: data['documentName']?.toString(),
      isCompleted: data['isCompleted'] == true,
      isLocked: data['isLocked'] == true,
    );
  }
}