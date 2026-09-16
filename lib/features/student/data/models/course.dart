enum CourseStatus { draft, published, archived }

enum CourseLevel { beginner, intermediate, advanced }

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.categoryId,
    required this.categoryName,
    required this.status,
    required this.level,
    this.shortDescription,
    this.thumbnailUrl,
    this.price = 0,
    this.rating = 0,
    this.ratingCount = 0,
    this.learnerCount = 0,
    this.sectionCount = 0,
    this.lessonCount = 0,
    this.totalDurationMinutes = 0,
    this.isEnrolled = false,
    this.progressPercent = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final String categoryId;
  final String categoryName;
  final CourseStatus status;
  final CourseLevel level;
  final String? shortDescription;
  final String? thumbnailUrl;
  final double price;
  final double rating;
  final int ratingCount;
  final int learnerCount;
  final int sectionCount;
  final int lessonCount;
  final int totalDurationMinutes;
  final bool isEnrolled;
  final int progressPercent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Course.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    // Category may be a nested object or a flat pair of fields.
    final categoryJson = data['category'] as Map<String, dynamic>?;
    final instructorJson =
    data['instructor'] as Map<String, dynamic>?;

    final statusStr =
    ((data['status'] ?? 'DRAFT') as String).toUpperCase();
    final levelStr =
    ((data['level'] ?? 'BEGINNER') as String).toUpperCase();

    return Course(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      instructorId: (data['instructorId'] ??
          instructorJson?['id'] ??
          instructorJson?['_id'] ??
          '')
          .toString(),
      instructorName: (data['instructorName'] ??
          instructorJson?['fullName'] ??
          instructorJson?['name'] ??
          '')
          .toString(),
      categoryId: (data['categoryId'] ??
          categoryJson?['id'] ??
          categoryJson?['_id'] ??
          '')
          .toString(),
      categoryName: (data['categoryName'] ??
          categoryJson?['name'] ??
          '')
          .toString(),
      status: CourseStatus.values.firstWhere(
            (s) => s.name.toUpperCase() == statusStr,
        orElse: () => CourseStatus.draft,
      ),
      level: CourseLevel.values.firstWhere(
            (l) => l.name.toUpperCase() == levelStr,
        orElse: () => CourseLevel.beginner,
      ),
      shortDescription: data['shortDescription']?.toString(),
      thumbnailUrl:
      (data['thumbnailUrl'] ?? data['thumbnail'])?.toString(),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      learnerCount: (data['learnerCount'] as num?)?.toInt() ?? 0,
      sectionCount: (data['sectionCount'] as num?)?.toInt() ?? 0,
      lessonCount: (data['lessonCount'] as num?)?.toInt() ?? 0,
      totalDurationMinutes:
      (data['totalDurationMinutes'] as num?)?.toInt() ?? 0,
      isEnrolled: data['isEnrolled'] == true,
      progressPercent:
      (data['progressPercent'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}