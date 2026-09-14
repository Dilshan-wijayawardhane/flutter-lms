import 'models/mock_notification.dart';

class MockNotifications {
  MockNotifications._();

  static final List<MockNotification> student1 = [
    MockNotification(
      id: 'notification_001',
      title: 'Assignment graded',
      message:
      'Your submission for "Build Your First Flutter App" has been graded. '
          'Score: 92/100.',
      type: NotificationType.assignment,
      isRead: false,
      createdAt: DateTime(2025, 4, 12, 9, 5),
    ),
    MockNotification(
      id: 'notification_002',
      title: 'Resubmission requested',
      message:
      'Your "Architecture Reflection" submission needs resubmission. '
          'Please check the feedback.',
      type: NotificationType.assignment,
      isRead: false,
      createdAt: DateTime(2025, 5, 1, 10, 32),
    ),
    MockNotification(
      id: 'notification_003',
      title: 'New course published',
      message:
      'A new course "Advanced Flutter Architecture" is now available.',
      type: NotificationType.course,
      isRead: true,
      createdAt: DateTime(2025, 2, 5, 12, 0),
    ),
    MockNotification(
      id: 'notification_004',
      title: 'Quiz available',
      message:
      'The "Widgets Deep Dive Quiz" is now available in your course.',
      type: NotificationType.quiz,
      isRead: true,
      createdAt: DateTime(2025, 3, 22, 8, 15),
    ),
  ];

  static List<MockNotification> get all => student1;

  static int get unreadCount => all.where((n) => !n.isRead).length;
}