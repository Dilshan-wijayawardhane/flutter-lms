import '../../../../core/network/api_client.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/lesson.dart';
import '../models/review.dart';
import '../models/section.dart';

class CourseService {
  CourseService(this._client);
  final ApiClient _client;

  static const String _listPath = '/api/v1/courses';

  /// Browse published courses. Search + category filters are query params.
  Future<List<Course>> listPublished({
    String? search,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _client.get<dynamic>(
      _listPath,
      query: {
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Course.fromJson)
        .toList();
  }

  static const String _instructorListPath =
      '/api/v1/courses/instructor/me';


  /// List enrollments for a course (instructor / admin).
  Future<List<Enrollment>> listCourseEnrollments(String courseId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/courses/$courseId/enrollments',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(Enrollment.fromJson)
        .toList();
  }

  /// Get a single enrollment by ID.
  Future<Enrollment> getEnrollment(String enrollmentId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/api/v1/enrollments/$enrollmentId',
    );
    return Enrollment.fromJson(res);
  }

  /// List reviews for a course.
  Future<List<CourseReview>> listCourseReviews(String courseId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/courses/$courseId/reviews',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(CourseReview.fromJson)
        .toList();
  }

  Future<List<Course>> listInstructorCourses() async {
    final res = await _client.get<dynamic>(_instructorListPath);
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(Course.fromJson)
        .toList();
  }

  Future<Course> createCourse({
    required String title,
    required String description,
    String? shortDescription,
    required String categoryId,
    required CourseLevel level,
    double price = 0,
    bool publish = false,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      _listPath,
      data: {
        'title': title,
        'description': description,
        if (shortDescription != null && shortDescription.isNotEmpty)
          'shortDescription': shortDescription,
        'categoryId': categoryId,
        'level': level.name.toUpperCase(),
        'price': price,
        'publish': publish,
      },
    );
    return Course.fromJson(res);
  }

  Future<Course> updateCourse({
    required String courseId,
    String? title,
    String? description,
    String? shortDescription,
    String? categoryId,
    CourseLevel? level,
    double? price,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (shortDescription != null) {
      body['shortDescription'] = shortDescription;
    }
    if (categoryId != null) body['categoryId'] = categoryId;
    if (level != null) body['level'] = level.name.toUpperCase();
    if (price != null) body['price'] = price;

    final res = await _client.patch<Map<String, dynamic>>(
      '$_listPath/$courseId',
      data: body,
    );
    return Course.fromJson(res);
  }

  Future<Course> publishCourse(String courseId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '$_listPath/$courseId/publish',
    );
    return Course.fromJson(res);
  }

  Future<Course> archiveCourse(String courseId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '$_listPath/$courseId/archive',
    );
    return Course.fromJson(res);
  }

  Future<void> deleteCourse(String courseId) async {
    await _client.delete<dynamic>('$_listPath/$courseId');
  }

  // ---- Sections ----
  Future<CourseSection> createSection({
    required String courseId,
    required String title,
    String? description,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '$_listPath/$courseId/sections',
      data: {
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    return CourseSection.fromJson(res);
  }

  Future<CourseSection> updateSection({
    required String sectionId,
    String? title,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;

    final res = await _client.patch<Map<String, dynamic>>(
      '/api/v1/sections/$sectionId',
      data: body,
    );
    return CourseSection.fromJson(res);
  }

  Future<void> deleteSection(String sectionId) async {
    await _client.delete<dynamic>('/api/v1/sections/$sectionId');
  }

  Future<void> reorderSections({
    required String courseId,
    required List<String> sectionIdsInOrder,
  }) async {
    await _client.post<dynamic>(
      '$_listPath/$courseId/sections/reorder',
      data: {'sectionIds': sectionIdsInOrder},
    );
  }

  // ---- Lessons ----
  Future<Lesson> createLesson({
    required String sectionId,
    required String title,
    required LessonType type,
    required int durationMinutes,
    String? content,
    bool publish = false,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/sections/$sectionId/lessons',
      data: {
        'title': title,
        'type': type.name.toUpperCase(),
        'durationMinutes': durationMinutes,
        if (content != null && content.isNotEmpty) 'content': content,
        'publish': publish,
      },
    );
    return Lesson.fromJson(res);
  }

  Future<Lesson> updateLesson({
    required String lessonId,
    String? title,
    int? durationMinutes,
    String? content,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (durationMinutes != null) body['durationMinutes'] = durationMinutes;
    if (content != null) body['content'] = content;

    final res = await _client.patch<Map<String, dynamic>>(
      '/api/v1/lessons/$lessonId',
      data: body,
    );
    return Lesson.fromJson(res);
  }

  Future<Lesson> publishLesson(String lessonId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/lessons/$lessonId/publish',
    );
    return Lesson.fromJson(res);
  }

  Future<void> deleteLesson(String lessonId) async {
    await _client.delete<dynamic>('/api/v1/lessons/$lessonId');
  }

  Future<void> reorderLessons({
    required String sectionId,
    required List<String> lessonIdsInOrder,
  }) async {
    await _client.post<dynamic>(
      '/api/v1/sections/$sectionId/lessons/reorder',
      data: {'lessonIds': lessonIdsInOrder},
    );
  }

  Future<Course> getCourse(String courseId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '$_listPath/$courseId',
    );
    return Course.fromJson(res);
  }

  /// Fetch sections for a course.
  Future<List<CourseSection>> listSections(String courseId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/courses/$courseId/sections',
    );
    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map(CourseSection.fromJson)
        .toList();
  }

  /// Fetch lessons for a section.
  Future<List<Lesson>> listLessons(String sectionId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/sections/$sectionId/lessons',
    );
    final list = _extractList(res);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Lesson.fromJson)
        .toList();
  }

  /// Fetch a single lesson by ID.
  Future<Lesson> getLesson(String lessonId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/api/v1/lessons/$lessonId',
    );
    return Lesson.fromJson(res);
  }

  /// Extracts a list from a variety of response envelopes.
  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        if (data['items'] is List) return data['items'] as List;
        if (data['results'] is List) return data['results'] as List;
        if (data['courses'] is List) return data['courses'] as List;
        if (data['sections'] is List) return data['sections'] as List;
        if (data['lessons'] is List) return data['lessons'] as List;
      }
      if (res['items'] is List) return res['items'] as List;
      if (res['results'] is List) return res['results'] as List;
      if (res['courses'] is List) return res['courses'] as List;
      if (res['sections'] is List) return res['sections'] as List;
      if (res['lessons'] is List) return res['lessons'] as List;
    }
    return const [];
  }
}