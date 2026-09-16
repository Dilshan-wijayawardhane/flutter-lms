import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_client.dart';
import '../models/assignment.dart';
import '../models/submission.dart';

class AssignmentService {
  AssignmentService(this._client);
  final ApiClient _client;

  /// List assignments for a course.
  Future<List<Assignment>> listForCourse(String courseId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/courses/$courseId/assignments',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(Assignment.fromJson)
        .toList();
  }

  /// Student-facing assignment list across enrolled courses.
  Future<List<Assignment>> listMine() async {
    final res = await _client.get<dynamic>(
      '/api/v1/assignments/me',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(Assignment.fromJson)
        .toList();
  }

  Future<Assignment> getAssignment(String assignmentId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/api/v1/assignments/$assignmentId',
    );
    return Assignment.fromJson(res);
  }

  /// Submit with text only.
  Future<Submission> submitText({
    required String assignmentId,
    required String text,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/assignments/$assignmentId/submit/text',
      data: {'text': text},
    );
    return Submission.fromJson(res);
  }

  /// Submit with a file (multipart).
  Future<Submission> submitFile({
    required String assignmentId,
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: mimeType != null
            ? MediaType.parse(mimeType)
            : null,
      ),
    });

    final res = await _client.upload<Map<String, dynamic>>(
      '/api/v1/assignments/$assignmentId/submit/file',
      formData: formData,
      onSendProgress: onSendProgress,
    );
    return Submission.fromJson(res);
  }

  /// Replace a submission file (for resubmission).
  Future<Submission> replaceFile({
    required String assignmentId,
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: mimeType != null
            ? MediaType.parse(mimeType)
            : null,
      ),
    });

    final res = await _client.upload<Map<String, dynamic>>(
      '/api/v1/assignments/$assignmentId/submission/file',
      formData: formData,
      onSendProgress: onSendProgress,
    );
    return Submission.fromJson(res);
  }

  /// Fetch my submission for an assignment (if any).
  Future<Submission?> getMySubmission(String assignmentId) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/api/v1/assignments/$assignmentId/submission/me',
      );
      return Submission.fromJson(res);
    } catch (_) {
      return null;
    }
  }

  // ---- Instructor endpoints ----

  Future<Assignment> createAssignment({
    required String courseId,
    required String title,
    required String description,
    DateTime? dueDate,
    int maxPoints = 100,
    bool allowTextSubmission = true,
    bool allowFileSubmission = true,
    bool publish = false,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/courses/$courseId/assignments',
      data: {
        'title': title,
        'description': description,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        'maxPoints': maxPoints,
        'allowTextSubmission': allowTextSubmission,
        'allowFileSubmission': allowFileSubmission,
        'publish': publish,
      },
    );
    return Assignment.fromJson(res);
  }

  Future<Assignment> updateAssignment({
    required String assignmentId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxPoints,
    bool? allowTextSubmission,
    bool? allowFileSubmission,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();
    if (maxPoints != null) body['maxPoints'] = maxPoints;
    if (allowTextSubmission != null) {
      body['allowTextSubmission'] = allowTextSubmission;
    }
    if (allowFileSubmission != null) {
      body['allowFileSubmission'] = allowFileSubmission;
    }

    final res = await _client.patch<Map<String, dynamic>>(
      '/api/v1/assignments/$assignmentId',
      data: body,
    );
    return Assignment.fromJson(res);
  }

  Future<void> deleteAssignment(String assignmentId) async {
    await _client.delete<dynamic>('/api/v1/assignments/$assignmentId');
  }

  Future<Assignment> publishAssignment(String assignmentId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/assignments/$assignmentId/publish',
    );
    return Assignment.fromJson(res);
  }

  /// Instructor: list all submissions for an assignment.
  Future<List<Submission>> listSubmissions(String assignmentId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/assignments/$assignmentId/submissions',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(Submission.fromJson)
        .toList();
  }

  /// Instructor: get a single submission by ID.
  Future<Submission> getSubmission(String submissionId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/api/v1/submissions/$submissionId',
    );
    return Submission.fromJson(res);
  }

  /// Instructor: grade a submission.
  Future<Submission> gradeSubmission({
    required String submissionId,
    required int score,
    required String feedback,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/submissions/$submissionId/grade',
      data: {'score': score, 'feedback': feedback},
    );
    return Submission.fromJson(res);
  }

  /// Instructor: request resubmission.
  Future<Submission> requestResubmission({
    required String submissionId,
    required String feedback,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/submissions/$submissionId/request-resubmission',
      data: {'feedback': feedback},
    );
    return Submission.fromJson(res);
  }

  /// Instructor: list assignments for a course.
  Future<List<Assignment>> listForCourseInstructor(
      String courseId,
      ) async {
    final res = await _client.get<dynamic>(
      '/api/v1/courses/$courseId/assignments',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(Assignment.fromJson)
        .toList();
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        for (final key in ['items', 'results', 'assignments',
          'submissions']) {
          if (data[key] is List) return data[key] as List;
        }
      }
      for (final key in ['items', 'results', 'assignments',
        'submissions']) {
        if (res[key] is List) return res[key] as List;
      }
    }
    return const [];
  }
}