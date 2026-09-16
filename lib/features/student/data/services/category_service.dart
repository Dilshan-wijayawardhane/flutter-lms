import '../../../../core/network/api_client.dart';
import '../models/category.dart';

class CategoryService {
  CategoryService(this._client);
  final ApiClient _client;

  static const String _path = '/api/v1/categories';


  Future<CourseCategory> createCategory({
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      _path,
      data: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        'isActive': isActive,
      },
    );
    return CourseCategory.fromJson(res);
  }

  Future<CourseCategory> updateCategory({
    required String categoryId,
    String? name,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;

    final res = await _client.patch<Map<String, dynamic>>(
      '$_path/$categoryId',
      data: body,
    );
    return CourseCategory.fromJson(res);
  }

  Future<void> setCategoryActive({
    required String categoryId,
    required bool active,
  }) async {
    await _client.post<dynamic>(
      '$_path/$categoryId/${active ? "activate" : "deactivate"}',
    );
  }

  Future<List<CourseCategory>> listCategories() async {
    final res = await _client.get<dynamic>(_path);
    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map(CourseCategory.fromJson)
        .toList();
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['categories'] is List) {
        return data['categories'] as List;
      }
      if (res['categories'] is List) return res['categories'] as List;
    }
    return const [];
  }
}