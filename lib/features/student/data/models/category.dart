class CourseCategory {
  const CourseCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.courseCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final int courseCount;

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return CourseCategory(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      description: data['description']?.toString(),
      isActive: data['isActive'] != false && data['active'] != false,
      courseCount: (data['courseCount'] as num?)?.toInt() ?? 0,
    );
  }
}