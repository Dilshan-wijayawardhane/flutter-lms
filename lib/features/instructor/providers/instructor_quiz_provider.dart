import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../../student/data/models/quiz.dart';
import '../../student/data/models/quiz_attempt.dart';
import '../../student/data/models/quiz_question.dart';
import '../../student/data/services/quiz_service.dart';

class InstructorQuizProvider extends ChangeNotifier {
  InstructorQuizProvider({QuizService? service})
      : _service = service ?? QuizService(ApiClient.instance);

  final QuizService _service;

  final Map<String, LoadState> _listState = {};
  final Map<String, List<Quiz>> _quizzes = {};
  final Map<String, String> _listError = {};

  final Map<String, LoadState> _questionsState = {};
  final Map<String, List<QuizQuestion>> _questions = {};

  final Map<String, LoadState> _attemptsState = {};
  final Map<String, List<QuizAttempt>> _attempts = {};

  LoadState listStateFor(String courseId) =>
      _listState[courseId] ?? LoadState.initial;
  List<Quiz> quizzesFor(String courseId) =>
      _quizzes[courseId] ?? const [];
  String? listErrorFor(String courseId) => _listError[courseId];

  LoadState questionsStateFor(String quizId) =>
      _questionsState[quizId] ?? LoadState.initial;
  List<QuizQuestion> questionsFor(String quizId) =>
      _questions[quizId] ?? const [];

  LoadState attemptsStateFor(String quizId) =>
      _attemptsState[quizId] ?? LoadState.initial;
  List<QuizAttempt> attemptsFor(String quizId) =>
      _attempts[quizId] ?? const [];

  Quiz? quizById(String courseId, String quizId) {
    for (final q in _quizzes[courseId] ?? const <Quiz>[]) {
      if (q.id == quizId) return q;
    }
    return null;
  }

  Future<void> loadQuizzes(String courseId, {bool force = false}) async {
    if (_listState[courseId] == LoadState.loading) return;
    if (!force && _listState[courseId] == LoadState.success) return;

    _listState[courseId] = LoadState.loading;
    _listError.remove(courseId);
    notifyListeners();

    try {
      _quizzes[courseId] = await _service.listForCourse(courseId);
      _listState[courseId] = LoadState.success;
    } on ApiException catch (e) {
      _listError[courseId] = e.message;
      _listState[courseId] = LoadState.error;
    } catch (_) {
      _listError[courseId] = 'Could not load quizzes.';
      _listState[courseId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<Quiz?> createQuiz({
    required String courseId,
    required String title,
    String? description,
    int durationMinutes = 20,
    int passingScore = 60,
    int maxAttempts = 3,
    bool publish = false,
  }) async {
    try {
      final q = await _service.createQuiz(
        courseId: courseId,
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        passingScore: passingScore,
        maxAttempts: maxAttempts,
        publish: publish,
      );
      _quizzes[courseId] = [q, ...(_quizzes[courseId] ?? [])];
      notifyListeners();
      return q;
    } on ApiException catch (e) {
      _listError[courseId] = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateQuiz({
    required String courseId,
    required String quizId,
    String? title,
    String? description,
    int? durationMinutes,
    int? passingScore,
    int? maxAttempts,
  }) async {
    try {
      final updated = await _service.updateQuiz(
        quizId: quizId,
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        passingScore: passingScore,
        maxAttempts: maxAttempts,
      );
      _replace(courseId, updated);
      return true;
    } on ApiException catch (e) {
      _listError[courseId] = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> publishQuiz({
    required String courseId,
    required String quizId,
  }) async {
    try {
      final updated = await _service.publishQuiz(quizId);
      _replace(courseId, updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteQuiz({
    required String courseId,
    required String quizId,
  }) async {
    try {
      await _service.deleteQuiz(quizId);
      _quizzes[courseId] =
          (_quizzes[courseId] ?? []).where((q) => q.id != quizId).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _replace(String courseId, Quiz q) {
    _quizzes[courseId] = (_quizzes[courseId] ?? [])
        .map((x) => x.id == q.id ? q : x)
        .toList();
    notifyListeners();
  }

  // ---- Questions ----
  Future<void> loadQuestions(String quizId, {bool force = false}) async {
    if (_questionsState[quizId] == LoadState.loading) return;
    if (!force && _questionsState[quizId] == LoadState.success) return;

    _questionsState[quizId] = LoadState.loading;
    notifyListeners();

    try {
      _questions[quizId] = await _service.getQuestions(quizId);
      _questionsState[quizId] = LoadState.success;
    } catch (_) {
      _questionsState[quizId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<QuizQuestion?> createQuestion({
    required String quizId,
    required String text,
    required List<String> options,
    required int correctOptionIndex,
    required int points,
  }) async {
    try {
      final q = await _service.createQuestion(
        quizId: quizId,
        text: text,
        options: options,
        correctOptionIndex: correctOptionIndex,
        points: points,
      );
      _questions[quizId] = [...(_questions[quizId] ?? []), q];
      notifyListeners();
      return q;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateQuestion({
    required String quizId,
    required String questionId,
    String? text,
    List<String>? options,
    int? correctOptionIndex,
    int? points,
  }) async {
    try {
      final updated = await _service.updateQuestion(
        questionId: questionId,
        text: text,
        options: options,
        correctOptionIndex: correctOptionIndex,
        points: points,
      );
      _questions[quizId] = (_questions[quizId] ?? [])
          .map((q) => q.id == questionId ? updated : q)
          .toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteQuestion({
    required String quizId,
    required String questionId,
  }) async {
    try {
      await _service.deleteQuestion(questionId);
      _questions[quizId] = (_questions[quizId] ?? [])
          .where((q) => q.id != questionId)
          .toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- Attempts ----
  Future<void> loadAttempts(String quizId, {bool force = false}) async {
    if (_attemptsState[quizId] == LoadState.loading) return;
    if (!force && _attemptsState[quizId] == LoadState.success) return;

    _attemptsState[quizId] = LoadState.loading;
    notifyListeners();

    try {
      _attempts[quizId] = await _service.listAllAttempts(quizId);
      _attemptsState[quizId] = LoadState.success;
    } catch (_) {
      _attemptsState[quizId] = LoadState.error;
    }
    notifyListeners();
  }
}