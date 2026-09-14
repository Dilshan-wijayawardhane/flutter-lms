/// Lesson type — matches backend values.
enum LessonType {
  text,
  video,
  document;

  String get wireValue {
    switch (this) {
      case LessonType.text:
        return 'TEXT';
      case LessonType.video:
        return 'VIDEO';
      case LessonType.document:
        return 'DOCUMENT';
    }
  }

  String get label {
    switch (this) {
      case LessonType.text:
        return 'Text Lesson';
      case LessonType.video:
        return 'Video Lesson';
      case LessonType.document:
        return 'Document Lesson';
    }
  }
}

enum LessonStatus {
  draft,
  published;

  String get wireValue {
    switch (this) {
      case LessonStatus.draft:
        return 'DRAFT';
      case LessonStatus.published:
        return 'PUBLISHED';
    }
  }

  String get label {
    switch (this) {
      case LessonStatus.draft:
        return 'Draft';
      case LessonStatus.published:
        return 'Published';
    }
  }
}

class MockLesson {
  const MockLesson({
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

  // TEXT
  final String? content;

  // VIDEO
  final String? videoUrl;

  // DOCUMENT
  final String? documentUrl;
  final String? documentName;

  final bool isCompleted;
  final bool isLocked;

  MockLesson copyWith({
    String? title,
    LessonType? type,
    LessonStatus? status,
    int? order,
    int? durationMinutes,
    String? content,
    String? videoUrl,
    String? documentUrl,
    String? documentName,
    bool? isCompleted,
    bool? isLocked,
  }) {
    return MockLesson(
      id: id,
      sectionId: sectionId,
      courseId: courseId,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      order: order ?? this.order,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      documentName: documentName ?? this.documentName,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  factory MockLesson.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockLesson.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockLesson.toJson');
  }
}