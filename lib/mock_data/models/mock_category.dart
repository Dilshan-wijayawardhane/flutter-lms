class MockCategory {
  const MockCategory({
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

  MockCategory copyWith({
    String? name,
    String? description,
    bool? isActive,
    int? courseCount,
  }) {
    return MockCategory(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      courseCount: courseCount ?? this.courseCount,
    );
  }

  factory MockCategory.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockCategory.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockCategory.toJson');
  }
}