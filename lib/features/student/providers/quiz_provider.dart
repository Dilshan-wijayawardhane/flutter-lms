import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../data/models/quiz.dart';
import '../data/models/quiz_attempt.dart';
import '../data/models/quiz_question.dart';
import '../data/models/quiz_submission.dart';
import '../data/services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider({QuizService? service})
      : _service = service ?? QuizService(ApiClient.instance);

  final QuizService _service;

  final Map<String, LoadState> _listByCourse = {};
  final Map<String, List<Quiz>> _quizzesByCourse = {};
  final Map<String, String> _listErrorByCourse = {};

  final Map<String, LoadState> _detailState = {};
  final Map<String, Quiz> _quizzes = {};
  final Map<String, List<QuizQuestion>> _questions = {};
  final Map<String, String> _detailError = {};

  final Map<String, LoadState> _attemptsState = {};
  final Map<String, List<QuizAttempt>> _attempts = {};

  // ---- Getters ----
  LoadState listStateFor(String courseId) =>
      _listByCourse[courseId] ?? LoadState.initial;
  List<Quiz> listFor(String courseId) =>
      _quizzesByCourse[courseId] ?? const [];
  String? listErrorFor(String courseId) => _listErrorByCourse[courseId];

  LoadState detailStateFor(String quizId) =>
      _detailState[quizId] ?? LoadState.initial;
  Quiz? quizById(String quizId) => _quizzes[quizId];
  List<QuizQuestion> questionsFor(String quizId) =>
      _questions[quizId] ?? const [];
  String? detailErrorFor(String quizId) => _detailError[quizId];

  LoadState attemptsStateFor(String quizId) =>
      _attemptsState[quizId] ?? LoadState.initial;
  List<QuizAttempt> attemptsFor(String quizId) =>
      _attempts[quizId] ?? const [];

  // ---- Actions ----
  Future<void> loadList(String courseId, {bool force = false}) async {
    if (_listByCourse[courseId] == LoadState.loading) return;
    if (!force && _listByCourse[courseId] == LoadState.success) return;

    _listByCourse[courseId] = LoadState.loading;
    _listErrorByCourse.remove(courseId);
    notifyListeners();

    try {
      _quizzesByCourse[courseId] =
      await _service.listForCourse(courseId);
      _listByCourse[courseId] = LoadState.success;
    } on ApiException catch (e) {
      _listErrorByCourse[courseId] = e.message;
      _listByCourse[courseId] = LoadState.error;
    } catch (_) {
      _listErrorByCourse[courseId] = 'Could not load quizzes.';
      _listByCourse[courseId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadDetails(String quizId, {bool force = false}) async {
    if (_detailState[quizId] == LoadState.loading) return;
    if (!force && _detailState[quizId] == LoadState.success) return;

    _detailState[quizId] = LoadState.loading;
    _detailError.remove(quizId);
    notifyListeners();

    try {
      final quiz = await _service.getQuiz(quizId);
      final questions = await _service.getQuestions(quizId);
      _quizzes[quizId] = quiz;
      _questions[quizId] = questions;
      _detailState[quizId] = LoadState.success;
    } on ApiException catch (e) {
      _detailError[quizId] = e.message;
      _detailState[quizId] = LoadState.error;
    } catch (_) {
      _detailError[quizId] = 'Could not load quiz.';
      _detailState[quizId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<QuizStartResponse?> startAttempt(String quizId) async {
    try {
      return await _service.startAttempt(quizId);
    } on ApiException catch (e) {
      _detailError[quizId] = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _detailError[quizId] = 'Could not start attempt.';
      notifyListeners();
      return null;
    }
  }

  Future<QuizAttempt?> submitAttempt(QuizSubmission submission) async {
    try {
      return await _service.submitAttempt(submission);
    } on ApiException catch (e) {
      _detailError[submission.attemptId] = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadAttempts(String quizId, {bool force = false}) async {
    if (_attemptsState[quizId] == LoadState.loading) return;
    if (!force && _attemptsState[quizId] == LoadState.success) return;

    _attemptsState[quizId] = LoadState.loading;
    notifyListeners();

    try {
      _attempts[quizId] = await _service.listMyAttempts(quizId);
      _attemptsState[quizId] = LoadState.success;
    } catch (_) {
      _attemptsState[quizId] = LoadState.error;
    }
    notifyListeners();
  }
}