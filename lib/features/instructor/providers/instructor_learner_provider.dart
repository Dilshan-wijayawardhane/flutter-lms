import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../../student/data/models/enrollment.dart';
import '../../student/data/models/review.dart';
import '../../student/data/services/course_service.dart';

class InstructorLearnerProvider extends ChangeNotifier {
  InstructorLearnerProvider({CourseService? service})
      : _service = service ?? CourseService(ApiClient.instance);

  final CourseService _service;

  final Map<String, LoadState> _enrollState = {};
  final Map<String, List<Enrollment>> _enrollments = {};
  final Map<String, String> _error = {};

  final Map<String, LoadState> _reviewsState = {};
  final Map<String, List<CourseReview>> _reviews = {};

  LoadState enrollStateFor(String courseId) =>
      _enrollState[courseId] ?? LoadState.initial;
  List<Enrollment> enrollmentsFor(String courseId) =>
      _enrollments[courseId] ?? const [];
  String? enrollErrorFor(String courseId) => _error[courseId];

  LoadState reviewsStateFor(String courseId) =>
      _reviewsState[courseId] ?? LoadState.initial;
  List<CourseReview> reviewsFor(String courseId) =>
      _reviews[courseId] ?? const [];

  Future<void> loadEnrollments(String courseId,
      {bool force = false}) async {
    if (_enrollState[courseId] == LoadState.loading) return;
    if (!force && _enrollState[courseId] == LoadState.success) return;

    _enrollState[courseId] = LoadState.loading;
    _error.remove(courseId);
    notifyListeners();

    try {
      _enrollments[courseId] =
      await _service.listCourseEnrollments(courseId);
      _enrollState[courseId] = LoadState.success;
    } on ApiException catch (e) {
      _error[courseId] = e.message;
      _enrollState[courseId] = LoadState.error;
    } catch (_) {
      _error[courseId] = 'Could not load learners.';
      _enrollState[courseId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadReviews(String courseId, {bool force = false}) async {
    if (_reviewsState[courseId] == LoadState.loading) return;
    if (!force && _reviewsState[courseId] == LoadState.success) return;

    _reviewsState[courseId] = LoadState.loading;
    notifyListeners();

    try {
      _reviews[courseId] = await _service.listCourseReviews(courseId);
      _reviewsState[courseId] = LoadState.success;
    } catch (_) {
      _reviewsState[courseId] = LoadState.error;
    }
    notifyListeners();
  }
}