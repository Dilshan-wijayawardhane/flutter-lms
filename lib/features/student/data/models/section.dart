class CourseSection {
  const CourseSection({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
    this.description,
    this.lessonCount = 0,
  });

  final String id;
  final String courseId;
  final String title;
  final int order;
  final String? description;
  final int lessonCount;

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return CourseSection(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      courseId:
      (data['courseId'] ?? data['course']?['id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      order: (data['order'] as num?)?.toInt() ?? 1,
      description: data['description']?.toString(),
      lessonCount: (data['lessonCount'] as num?)?.toInt() ?? 0,
    );
  }
}