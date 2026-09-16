import '../../../../core/network/api_client.dart';
import '../models/review.dart';

class ReviewService {
  ReviewService(this._client);
  final ApiClient _client;

  Future<List<CourseReview>> listForCourse(String courseId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/courses/$courseId/reviews',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(CourseReview.fromJson)
        .toList();
  }

  Future<List<CourseReview>> listMine() async {
    final res = await _client.get<dynamic>('/api/v1/reviews/me');
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(CourseReview.fromJson)
        .toList();
  }

  Future<CourseReview> create({
    required String courseId,
    required int rating,
    required String comment,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/courses/$courseId/reviews',
      data: {'rating': rating, 'comment': comment},
    );
    return CourseReview.fromJson(res);
  }

  Future<CourseReview> update({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    final res = await _client.patch<Map<String, dynamic>>(
      '/api/v1/reviews/$reviewId',
      data: {'rating': rating, 'comment': comment},
    );
    return CourseReview.fromJson(res);
  }

  Future<void> delete(String reviewId) async {
    await _client.delete<dynamic>('/api/v1/reviews/$reviewId');
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['items'] is List) {
        return data['items'] as List;
      }
      if (data is Map<String, dynamic> && data['reviews'] is List) {
        return data['reviews'] as List;
      }
      if (res['items'] is List) return res['items'] as List;
      if (res['reviews'] is List) return res['reviews'] as List;
    }
    return const [];
  }
}