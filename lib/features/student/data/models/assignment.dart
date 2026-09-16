enum AssignmentStatus { draft, published }

class Assignment {
  const Assignment({
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

  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now());

  factory Assignment.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final courseJson = data['course'] as Map<String, dynamic>?;

    final statusStr =
    ((data['status'] ?? 'DRAFT') as String).toUpperCase();

    return Assignment(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      courseId: (data['courseId'] ?? courseJson?['id'] ?? '').toString(),
      courseName: (data['courseName'] ??
          courseJson?['title'] ??
          '')
          .toString(),
      title: (data['title'] ?? '').toString(),
      status: AssignmentStatus.values.firstWhere(
            (s) => s.name.toUpperCase() == statusStr,
        orElse: () => AssignmentStatus.draft,
      ),
      description: (data['description'] ?? '').toString(),
      dueDate: _parseDate(data['dueDate']),
      maxPoints: (data['maxPoints'] as num?)?.toInt() ?? 100,
      allowTextSubmission: data['allowTextSubmission'] != false,
      allowFileSubmission: data['allowFileSubmission'] != false,
      attachmentName: data['attachmentName']?.toString(),
      attachmentUrl: data['attachmentUrl']?.toString(),
      createdAt: _parseDate(data['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}