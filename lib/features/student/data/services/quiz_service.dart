import '../../../../core/network/api_client.dart';
import '../models/quiz.dart';
import '../models/quiz_attempt.dart';
import '../models/quiz_question.dart';
import '../models/quiz_submission.dart';

class QuizService {
  QuizService(this._client);
  final ApiClient _client;

  /// List quizzes for a course (student view).
  Future<List<Quiz>> listForCourse(String courseId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/courses/$courseId/quizzes',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(Quiz.fromJson)
        .toList();
  }

  /// Student quiz list (across all enrolled courses).
  Future<List<Quiz>> listMine() async {
    final res = await _client.get<dynamic>('/api/v1/quizzes');
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(Quiz.fromJson)
        .toList();
  }

  Future<Quiz> getQuiz(String quizId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/api/v1/quizzes/$quizId',
    );
    return Quiz.fromJson(res);
  }

  Future<List<QuizQuestion>> getQuestions(String quizId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/quizzes/$quizId/questions',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(QuizQuestion.fromJson)
        .toList();
  }

  /// Start a new attempt.
  Future<QuizStartResponse> startAttempt(String quizId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/quizzes/$quizId/start',
    );
    return QuizStartResponse.fromJson(res);
  }

  /// Submit an attempt.
  Future<QuizAttempt> submitAttempt(QuizSubmission submission) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/quizzes/attempts/${submission.attemptId}/submit',
      data: submission.toJson(),
    );
    return QuizAttempt.fromJson(res);
  }

  /// Attempt history for the current student.
  Future<List<QuizAttempt>> listMyAttempts(String quizId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/quizzes/$quizId/attempts/me',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(QuizAttempt.fromJson)
        .toList();
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        for (final key in ['items', 'results', 'quizzes', 'questions',
          'attempts']) {
          if (data[key] is List) return data[key] as List;
        }
      }
      for (final key in ['items', 'results', 'quizzes', 'questions',
        'attempts']) {
        if (res[key] is List) return res[key] as List;
      }
    }
    return const [];
  }
}