import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../../student/data/models/course.dart';
import '../../student/data/services/course_service.dart';

class AdminCourseProvider extends ChangeNotifier {
  AdminCourseProvider({CourseService? service})
      : _service = service ?? CourseService(ApiClient.instance);

  final CourseService _service;

  LoadState _state = LoadState.initial;
  List<Course> _courses = const [];
  String? _error;
  String _search = '';
  CourseStatus? _statusFilter;
  String? _categoryFilter;

  LoadState get state => _state;
  List<Course> get courses => _courses;
  String? get errorMessage => _error;
  String get search => _search;
  CourseStatus? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;

  Future<void> load({bool force = false}) async {
    if (_state == LoadState.loading) return;
    if (!force && _state == LoadState.success) return;

    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      // Backend returns all courses for admin, with filters as query params.
      _courses = await _service.listPublished(
        search: _search,
        categoryId: _categoryFilter,
        page: 1,
        pageSize: 100,
      );
      // Apply status filter locally if the backend doesn't support it.
      if (_statusFilter != null) {
        _courses = _courses
            .where((c) => c.status == _statusFilter)
            .toList();
      }
      _state = LoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Could not load courses.';
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> setSearch(String q) async {
    _search = q;
    await load(force: true);
  }

  Future<void> setFilters({
    CourseStatus? status,
    String? categoryId,
  }) async {
    _statusFilter = status;
    _categoryFilter = categoryId;
    await load(force: true);
  }

  Future<void> clearFilters() async {
    _statusFilter = null;
    _categoryFilter = null;
    await load(force: true);
  }

  Future<bool> archive(String courseId) async {
    try {
      final updated = await _service.archiveCourse(courseId);
      _courses = _courses
          .map((c) => c.id == courseId ? updated : c)
          .toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Course? byId(String id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }
}