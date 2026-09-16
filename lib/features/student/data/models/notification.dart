enum NotificationType { course, assignment, quiz, enrollment, system }

class AppNotification {
  const AppNotification({
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

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final typeStr =
    ((data['type'] ?? 'SYSTEM') as String).toUpperCase();

    return AppNotification(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? data['body'] ?? '').toString(),
      type: NotificationType.values.firstWhere(
            (t) => t.name.toUpperCase() == typeStr,
        orElse: () => NotificationType.system,
      ),
      isRead: data['isRead'] == true || data['read'] == true,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}