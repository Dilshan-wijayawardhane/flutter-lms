import '../../../../core/network/api_client.dart';
import '../models/enrollment.dart';
import '../models/lesson_progress.dart';

class EnrollmentService {
  EnrollmentService(this._client);

  final ApiClient _client;

  static const String _mePath = '/api/v1/enrollments/me';
  static const String _enrollPath = '/api/v1/enrollments';

  // ---------------------------------------------------------------------------
  // Enrollments
  // ---------------------------------------------------------------------------

  Future<List<Enrollment>> listMine() async {
    final res = await _client.get<dynamic>(_mePath);
    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Enrollment.fromJson)
        .toList();
  }

  Future<Enrollment> enroll(String courseId) async {
    final res = await _client.post<Map<String, dynamic>>(
      _enrollPath,
      data: {'courseId': courseId},
    );
    return Enrollment.fromJson(res);
  }

  Future<void> cancel(String enrollmentId) async {
    await _client.delete<dynamic>('$_enrollPath/$enrollmentId');
  }

  /// Get a single enrollment by ID.
  Future<Enrollment> getById(String enrollmentId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '$_enrollPath/$enrollmentId',
    );
    return Enrollment.fromJson(res);
  }

  // ---------------------------------------------------------------------------
  // Progress
  // ---------------------------------------------------------------------------

  /// Start a lesson — used for "I opened this lesson" tracking.
  Future<LessonProgress> startLesson(String lessonId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/lessons/$lessonId/start',
    );
    return LessonProgress.fromJson(res);
  }

  /// Complete a lesson.
  Future<LessonProgress> completeLesson(String lessonId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/lessons/$lessonId/complete',
    );
    return LessonProgress.fromJson(res);
  }

  /// Get progress for a specific enrollment.
  Future<LessonProgress> getProgress(String enrollmentId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '$_enrollPath/$enrollmentId/progress',
    );
    return LessonProgress.fromJson(res);
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['items'] is List) {
        return data['items'] as List;
      }
      if (data is Map<String, dynamic> &&
          data['enrollments'] is List) {
        return data['enrollments'] as List;
      }
      if (res['items'] is List) return res['items'] as List;
      if (res['enrollments'] is List) return res['enrollments'] as List;
    }
    return const [];
  }
}