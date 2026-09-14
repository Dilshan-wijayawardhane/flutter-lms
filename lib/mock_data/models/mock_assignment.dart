enum AssignmentStatus {
  draft,
  published;

  String get wireValue {
    switch (this) {
      case AssignmentStatus.draft:
        return 'DRAFT';
      case AssignmentStatus.published:
        return 'PUBLISHED';
    }
  }

  String get label {
    switch (this) {
      case AssignmentStatus.draft:
        return 'Draft';
      case AssignmentStatus.published:
        return 'Published';
    }
  }
}

class MockAssignment {
  const MockAssignment({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.status,
    required this.description,
    this.dueDate,
    this.maxPoints = 100,
    this.allowTextSubmission = true,
    this.allowFileSubmission = true,
    this.attachmentName,
    this.attachmentUrl,
    this.createdAt,
  });

  final String id;
  final String courseId;
  final String courseName;
  final String title;
  final AssignmentStatus status;
  final String description;
  final DateTime? dueDate;
  final int maxPoints;
  final bool allowTextSubmission;
  final bool allowFileSubmission;
  final String? attachmentName;
  final String? attachmentUrl;
  final DateTime? createdAt;

  MockAssignment copyWith({
    String? title,
    String? description,
    AssignmentStatus? status,
    DateTime? dueDate,
    int? maxPoints,
    bool? allowTextSubmission,
    bool? allowFileSubmission,
    String? attachmentName,
    String? attachmentUrl,
  }) {
    return MockAssignment(
      id: id,
      courseId: courseId,
      courseName: courseName,
      title: title ?? this.title,
      status: status ?? this.status,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      maxPoints: maxPoints ?? this.maxPoints,
      allowTextSubmission:
      allowTextSubmission ?? this.allowTextSubmission,
      allowFileSubmission:
      allowFileSubmission ?? this.allowFileSubmission,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt,
    );
  }

  factory MockAssignment.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockAssignment.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockAssignment.toJson');
  }
}