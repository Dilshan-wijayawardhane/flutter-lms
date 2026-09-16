import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../../student/data/models/enrollment.dart';
import '../../student/data/services/course_service.dart';

class AdminEnrollmentProvider extends ChangeNotifier {
  AdminEnrollmentProvider({CourseService? service})
      : _service = service ?? CourseService(ApiClient.instance);

  final CourseService _service;

  LoadState _state = LoadState.initial;
  List<Enrollment> _enrollments = const [];
  String? _error;

  LoadState get state => _state;
  List<Enrollment> get enrollments => _enrollments;
  String? get errorMessage => _error;

  Future<void> load(String courseId, {bool force = false}) async {
    if (_state == LoadState.loading) return;
    if (!force && _state == LoadState.success) return;

    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _enrollments = await _service.listCourseEnrollments(courseId);
      _state = LoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Could not load enrollments.';
      _state = LoadState.error;
    }
    notifyListeners();
  }
}