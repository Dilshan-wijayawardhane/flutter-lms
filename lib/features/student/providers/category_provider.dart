import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../data/models/category.dart';
import '../data/services/category_service.dart';

enum LoadState { initial, loading, success, error }

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({CategoryService? service})
      : _service = service ?? CategoryService(ApiClient.instance);

  final CategoryService _service;

  LoadState _state = LoadState.initial;
  List<CourseCategory> _categories = const [];
  String? _errorMessage;

  LoadState get state => _state;
  List<CourseCategory> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadState.loading;


  Future<CourseCategory?> create({
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    try {
      final c = await _service.createCategory(
        name: name,
        description: description,
        isActive: isActive,
      );
      _categories = [c, ..._categories];
      notifyListeners();
      return c;
    } catch (_) {
      return null;
    }
  }

  Future<bool> update({
    required String categoryId,
    String? name,
    String? description,
  }) async {
    try {
      final updated = await _service.updateCategory(
        categoryId: categoryId,
        name: name,
        description: description,
      );
      _categories = _categories
          .map((c) => c.id == categoryId ? updated : c)
          .toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setActive(String categoryId, bool active) async {
    try {
      await _service.setCategoryActive(
        categoryId: categoryId,
        active: active,
      );
      _categories = _categories.map((c) {
        if (c.id != categoryId) return c;
        return CourseCategory(
          id: c.id,
          name: c.name,
          description: c.description,
          isActive: active,
          courseCount: c.courseCount,
        );
      }).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> load({bool force = false}) async {
    if (_state == LoadState.loading) return;
    if (!force && _state == LoadState.success) return;

    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _service.listCategories();
      _state = LoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = LoadState.error;
    } catch (_) {
      _errorMessage = 'Could not load categories.';
      _state = LoadState.error;
    }
    notifyListeners();
  }
}