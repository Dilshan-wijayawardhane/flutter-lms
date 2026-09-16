import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../data/models/course.dart';
import '../data/services/course_service.dart';

enum LoadState { initial, loading, success, error }

class CourseProvider extends ChangeNotifier {
  CourseProvider({CourseService? service})
      : _service = service ?? CourseService(ApiClient.instance);

  final CourseService _service;

  // ---- Browse state ----
  LoadState _browseState = LoadState.initial;
  List<Course> _courses = const [];
  String? _browseError;
  String _search = '';
  String? _categoryId;

  // ---- Details state (per courseId) ----
  final Map<String, Course> _details = {};
  final Map<String, LoadState> _detailsState = {};
  final Map<String, String> _detailsError = {};

  // ---- Getters ----
  LoadState get browseState => _browseState;
  List<Course> get courses => _courses;
  String? get browseError => _browseError;
  String get search => _search;
  String? get categoryId => _categoryId;

  // ---- Instructor-side state ----
  LoadState _myCoursesState = LoadState.initial;
  List<Course> _myCourses = const [];
  String? _myCoursesError;

  LoadState get myCoursesState => _myCoursesState;
  List<Course> get myCourses => _myCourses;
  String? get myCoursesError => _myCoursesError;

  Future<void> loadMyCourses({bool force = false}) async {
    if (_myCoursesState == LoadState.loading) return;
    if (!force && _myCoursesState == LoadState.success) return;

    _myCoursesState = LoadState.loading;
    _myCoursesError = null;
    notifyListeners();

    try {
      _myCourses = await _service.listInstructorCourses();
      _myCoursesState = LoadState.success;
    } on ApiException catch (e) {
      _myCoursesError = e.message;
      _myCoursesState = LoadState.error;
    } catch (_) {
      _myCoursesError = 'Could not load your courses.';
      _myCoursesState = LoadState.error;
    }
    notifyListeners();
  }

  Future<Course?> createCourse({
    required String title,
    required String description,
    String? shortDescription,
    required String categoryId,
    required CourseLevel level,
    double price = 0,
    bool publish = false,
  }) async {
    try {
      final created = await _service.createCourse(
        title: title,
        description: description,
        shortDescription: shortDescription,
        categoryId: categoryId,
        level: level,
        price: price,
        publish: publish,
      );
      _myCourses = [created, ..._myCourses];
      _myCoursesState = LoadState.success;
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      _myCoursesError = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _myCoursesError = 'Could not create course.';
      notifyListeners();
      return null;
    }
  }

  Future<Course?> updateCourse(
      String courseId, {
        String? title,
        String? description,
        String? shortDescription,
        String? categoryId,
        CourseLevel? level,
        double? price,
      }) async {
    try {
      final updated = await _service.updateCourse(
        courseId: courseId,
        title: title,
        description: description,
        shortDescription: shortDescription,
        categoryId: categoryId,
        level: level,
        price: price,
      );
      _myCourses = _myCourses
          .map((c) => c.id == courseId ? updated : c)
          .toList();
      _details[courseId] = updated;
      notifyListeners();
      return updated;
    } on ApiException catch (e) {
      _myCoursesError = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> publishCourse(String courseId) async {
    try {
      final updated = await _service.publishCourse(courseId);
      _replaceCourse(updated);
      return true;
    } on ApiException catch (e) {
      _myCoursesError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> archiveCourse(String courseId) async {
    try {
      final updated = await _service.archiveCourse(courseId);
      _replaceCourse(updated);
      return true;
    } on ApiException catch (e) {
      _myCoursesError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      await _service.deleteCourse(courseId);
      _myCourses =
          _myCourses.where((c) => c.id != courseId).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _myCoursesError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  void _replaceCourse(Course updated) {
    _myCourses = _myCourses
        .map((c) => c.id == updated.id ? updated : c)
        .toList();
    _details[updated.id] = updated;
    notifyListeners();
  }

  Course? courseById(String id) => _details[id];
  LoadState detailsStateFor(String id) =>
      _detailsState[id] ?? LoadState.initial;
  String? detailsErrorFor(String id) => _detailsError[id];

  // ---- Browse ----
  Future<void> browse({bool force = false}) async {
    if (_browseState == LoadState.loading) return;
    if (!force && _browseState == LoadState.success) return;

    _browseState = LoadState.loading;
    _browseError = null;
    notifyListeners();

    try {
      _courses = await _service.listPublished(
        search: _search,
        categoryId: _categoryId,
      );
      _browseState = LoadState.success;
    } on ApiException catch (e) {
      _browseError = e.message;
      _browseState = LoadState.error;
    } catch (_) {
      _browseError = 'Could not load courses.';
      _browseState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> setSearch(String value) async {
    _search = value;
    await browse(force: true);
  }

  Future<void> setCategory(String? id) async {
    _categoryId = id;
    await browse(force: true);
  }

  // ---- Details ----
  Future<void> loadDetails(String courseId, {bool force = false}) async {
    if (_detailsState[courseId] == LoadState.loading) return;
    if (!force && _details[courseId] != null) return;

    _detailsState[courseId] = LoadState.loading;
    _detailsError.remove(courseId);
    notifyListeners();

    try {
      final c = await _service.getCourse(courseId);
      _details[courseId] = c;
      _detailsState[courseId] = LoadState.success;
    } on ApiException catch (e) {
      _detailsError[courseId] = e.message;
      _detailsState[courseId] = LoadState.error;
    } catch (_) {
      _detailsError[courseId] = 'Could not load course details.';
      _detailsState[courseId] = LoadState.error;
    }
    notifyListeners();
  }

  /// Used after enrollment to update `isEnrolled` locally.
  void markEnrolled(String courseId) {
    final existing = _details[courseId];
    if (existing == null) return;
    _details[courseId] = Course(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      instructorId: existing.instructorId,
      instructorName: existing.instructorName,
      categoryId: existing.categoryId,
      categoryName: existing.categoryName,
      status: existing.status,
      level: existing.level,
      shortDescription: existing.shortDescription,
      thumbnailUrl: existing.thumbnailUrl,
      price: existing.price,
      rating: existing.rating,
      ratingCount: existing.ratingCount,
      learnerCount: existing.learnerCount,
      sectionCount: existing.sectionCount,
      lessonCount: existing.lessonCount,
      totalDurationMinutes: existing.totalDurationMinutes,
      isEnrolled: true,
      progressPercent: existing.progressPercent,
      createdAt: existing.createdAt,
      updatedAt: existing.updatedAt,
    );
    notifyListeners();
  }
}