import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../data/models/enrollment.dart';
import '../data/services/enrollment_service.dart';

enum LoadState { initial, loading, success, error }

class EnrollmentProvider extends ChangeNotifier {
  EnrollmentProvider({EnrollmentService? service})
      : _service = service ?? EnrollmentService(ApiClient.instance);

  final EnrollmentService _service;

  LoadState _state = LoadState.initial;
  List<Enrollment> _enrollments = const [];
  String? _errorMessage;
  final Set<String> _inFlightCourseIds = {};

  LoadState get state => _state;
  List<Enrollment> get enrollments => _enrollments;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadState.loading;

  bool isEnrolledIn(String courseId) =>
      _enrollments.any((e) => e.courseId == courseId);

  bool isEnrollInFlight(String courseId) =>
      _inFlightCourseIds.contains(courseId);

  Future<void> load({bool force = false}) async {
    if (_state == LoadState.loading) return;
    if (!force && _state == LoadState.success) return;

    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _enrollments = await _service.listMine();
      _state = LoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = LoadState.error;
    } catch (_) {
      _errorMessage = 'Could not load your enrollments.';
      _state = LoadState.error;
    }
    notifyListeners();
  }

  /// Enrolls in a course. Returns the created Enrollment on success.
  Future<Enrollment?> enroll(String courseId) async {
    if (_inFlightCourseIds.contains(courseId)) return null;
    _inFlightCourseIds.add(courseId);
    notifyListeners();

    try {
      final e = await _service.enroll(courseId);
      _enrollments = [..._enrollments, e];
      _state = LoadState.success;
      return e;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (_) {
      _errorMessage = 'Could not enroll. Please try again.';
      return null;
    } finally {
      _inFlightCourseIds.remove(courseId);
      notifyListeners();
    }
  }

  Future<bool> cancel(String enrollmentId) async {
    try {
      await _service.cancel(enrollmentId);
      _enrollments =
          _enrollments.where((e) => e.id != enrollmentId).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not cancel enrollment.';
      return false;
    }
  }

  Future<void> startLesson(String lessonId) async {
    try {
      await _service.startLesson(lessonId);
    } on ApiException {
      // Non-critical.
    } catch (_) {}
  }

  Future<bool> completeLesson(String lessonId) async {
    try {
      await _service.completeLesson(lessonId);
      // Refresh enrollments so progress % updates everywhere.
      await load(force: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Could not complete lesson.';
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _enrollments = const [];
    _state = LoadState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}