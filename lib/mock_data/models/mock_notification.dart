enum NotificationType {
  course,
  assignment,
  quiz,
  enrollment,
  system;

  String get wireValue {
    switch (this) {
      case NotificationType.course:
        return 'COURSE';
      case NotificationType.assignment:
        return 'ASSIGNMENT';
      case NotificationType.quiz:
        return 'QUIZ';
      case NotificationType.enrollment:
        return 'ENROLLMENT';
      case NotificationType.system:
        return 'SYSTEM';
    }
  }
}

class MockNotification {
  const MockNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime? createdAt;

  MockNotification copyWith({bool? isRead}) {
    return MockNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory MockNotification.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockNotification.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockNotification.toJson');
  }
}