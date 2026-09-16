import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../../student/data/models/review.dart';
import '../../student/data/services/course_service.dart';

class AdminReviewProvider extends ChangeNotifier {
  AdminReviewProvider({CourseService? service})
      : _service = service ?? CourseService(ApiClient.instance);

  final CourseService _service;

  LoadState _state = LoadState.initial;
  List<CourseReview> _reviews = const [];
  String? _error;
  String? _courseId;

  LoadState get state => _state;
  List<CourseReview> get reviews => _reviews;
  String? get errorMessage => _error;

  Future<void> load(String courseId, {bool force = false}) async {
    if (_state == LoadState.loading) return;
    if (!force && _courseId == courseId && _state == LoadState.success) {
      return;
    }

    _courseId = courseId;
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _service.listCourseReviews(courseId);
      _state = LoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Could not load reviews.';
      _state = LoadState.error;
    }
    notifyListeners();
  }

  /// Local optimistic toggle. Real endpoint for hide/show is admin-specific
  /// and will be added once the exact path is confirmed.
  void toggleVisibility(String reviewId) {
    _reviews = _reviews.map((r) {
      if (r.id != reviewId) return r;
      return CourseReview(
        id: r.id,
        courseId: r.courseId,
        courseName: r.courseName,
        studentId: r.studentId,
        studentName: r.studentName,
        studentAvatarUrl: r.studentAvatarUrl,
        rating: r.rating,
        comment: r.comment,
        isVisible: !r.isVisible,
        createdAt: r.createdAt,
        updatedAt: DateTime.now(),
      );
    }).toList();
    notifyListeners();
  }
}