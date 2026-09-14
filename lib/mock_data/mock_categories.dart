import 'models/mock_category.dart';

class MockCategories {
  MockCategories._();

  static const MockCategory mobileDevelopment = MockCategory(
    id: 'category_001',
    name: 'Mobile Development',
    description: 'iOS, Android, Flutter, React Native.',
    isActive: true,
    courseCount: 3,
  );

  static const MockCategory webDevelopment = MockCategory(
    id: 'category_002',
    name: 'Web Development',
    description: 'Frontend, backend, and full-stack web.',
    isActive: true,
    courseCount: 2,
  );

  static const MockCategory dataScience = MockCategory(
    id: 'category_003',
    name: 'Data Science',
    description: 'Analytics, ML, AI.',
    isActive: true,
    courseCount: 1,
  );

  static const MockCategory design = MockCategory(
    id: 'category_004',
    name: 'UI/UX Design',
    description: 'Product design, prototyping, research.',
    isActive: true,
    courseCount: 1,
  );

  static const MockCategory devOps = MockCategory(
    id: 'category_005',
    name: 'DevOps',
    description: 'CI/CD, containers, cloud.',
    isActive: false,
    courseCount: 0,
  );

  static const List<MockCategory> all = [
    mobileDevelopment,
    webDevelopment,
    dataScience,
    design,
    devOps,
  ];

  static List<MockCategory> get active =>
      all.where((c) => c.isActive).toList();
}