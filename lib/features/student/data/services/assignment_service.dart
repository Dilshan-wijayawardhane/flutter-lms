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