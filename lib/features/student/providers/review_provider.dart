import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../data/models/review.dart';
import '../data/services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({ReviewService? service})
      : _service = service ?? ReviewService(ApiClient.instance);

  final ReviewService _service;

  final Map<String, LoadState> _stateByCourse = {};
  final Map<String, List<CourseReview>> _reviewsByCourse = {};
  final Map<String, String> _errorByCourse = {};

  LoadState stateFor(String courseId) =>
      _stateByCourse[courseId] ?? LoadState.initial;
  List<CourseReview> reviewsFor(String courseId) =>
      _reviewsByCourse[courseId] ?? const [];
  String? errorFor(String courseId) => _errorByCourse[courseId];

  Future<void> loadForCourse(String courseId, {bool force = false}) async {
    if (_stateByCourse[courseId] == LoadState.loading) return;
    if (!force && _stateByCourse[courseId] == LoadState.success) return;

    _stateByCourse[courseId] = LoadState.loading;
    _errorByCourse.remove(courseId);
    notifyListeners();

    try {
      _reviewsByCourse[courseId] =
      await _service.listForCourse(courseId);
      _stateByCourse[courseId] = LoadState.success;
    } on ApiException catch (e) {
      _errorByCourse[courseId] = e.message;
      _stateByCourse[courseId] = LoadState.error;
    } catch (_) {
      _errorByCourse[courseId] = 'Could not load reviews.';
      _stateByCourse[courseId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<CourseReview?> create({
    required String courseId,
    required int rating,
    required String comment,
  }) async {
    try {
      final r = await _service.create(
        courseId: courseId,
        rating: rating,
        comment: comment,
      );
      final current = _reviewsByCourse[courseId] ?? [];
      _reviewsByCourse[courseId] = [r, ...current];
      notifyListeners();
      return r;
    } on ApiException catch (e) {
      _errorByCourse[courseId] = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> update({
    required String courseId,
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final updated = await _service.update(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
      final list = _reviewsByCourse[courseId] ?? [];
      _reviewsByCourse[courseId] = list
          .map((r) => r.id == reviewId ? updated : r)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorByCourse[courseId] = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete({
    required String courseId,
    required String reviewId,
  }) async {
    try {
      await _service.delete(reviewId);
      _reviewsByCourse[courseId] = (_reviewsByCourse[courseId] ?? [])
          .where((r) => r.id != reviewId)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorByCourse[courseId] = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }
}