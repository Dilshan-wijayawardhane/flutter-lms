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

  // ---- Instructor endpoints ----

  Future<Quiz> createQuiz({
    required String courseId,
    required String title,
    String? description,
    int durationMinutes = 20,
    int passingScore = 60,
    int maxAttempts = 3,
    bool publish = false,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/courses/$courseId/quizzes',
      data: {
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'durationMinutes': durationMinutes,
        'passingScore': passingScore,
        'maxAttempts': maxAttempts,
        'publish': publish,
      },
    );
    return Quiz.fromJson(res);
  }

  Future<Quiz> updateQuiz({
    required String quizId,
    String? title,
    String? description,
    int? durationMinutes,
    int? passingScore,
    int? maxAttempts,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (durationMinutes != null) body['durationMinutes'] = durationMinutes;
    if (passingScore != null) body['passingScore'] = passingScore;
    if (maxAttempts != null) body['maxAttempts'] = maxAttempts;

    final res = await _client.patch<Map<String, dynamic>>(
      '/api/v1/quizzes/$quizId',
      data: body,
    );
    return Quiz.fromJson(res);
  }

  Future<void> deleteQuiz(String quizId) async {
    await _client.delete<dynamic>('/api/v1/quizzes/$quizId');
  }

  Future<Quiz> publishQuiz(String quizId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/quizzes/$quizId/publish',
    );
    return Quiz.fromJson(res);
  }

  Future<QuizQuestion> createQuestion({
    required String quizId,
    required String text,
    required List<String> options,
    required int correctOptionIndex,
    required int points,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/api/v1/quizzes/$quizId/questions',
      data: {
        'text': text,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'points': points,
      },
    );
    return QuizQuestion.fromJson(res);
  }

  Future<QuizQuestion> updateQuestion({
    required String questionId,
    String? text,
    List<String>? options,
    int? correctOptionIndex,
    int? points,
  }) async {
    final body = <String, dynamic>{};
    if (text != null) body['text'] = text;
    if (options != null) body['options'] = options;
    if (correctOptionIndex != null) {
      body['correctOptionIndex'] = correctOptionIndex;
    }
    if (points != null) body['points'] = points;

    final res = await _client.patch<Map<String, dynamic>>(
      '/api/v1/questions/$questionId',
      data: body,
    );
    return QuizQuestion.fromJson(res);
  }

  Future<void> deleteQuestion(String questionId) async {
    await _client.delete<dynamic>('/api/v1/questions/$questionId');
  }

  /// Instructor view: all attempts for a quiz.
  Future<List<QuizAttempt>> listAllAttempts(String quizId) async {
    final res = await _client.get<dynamic>(
      '/api/v1/quizzes/$quizId/attempts',
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(QuizAttempt.fromJson)
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