import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../../student/data/models/assignment.dart';
import '../../student/data/models/submission.dart';
import '../../student/data/services/assignment_service.dart';

class InstructorAssignmentProvider extends ChangeNotifier {
  InstructorAssignmentProvider({AssignmentService? service})
      : _service = service ?? AssignmentService(ApiClient.instance);

  final AssignmentService _service;

  final Map<String, LoadState> _listState = {};
  final Map<String, List<Assignment>> _assignments = {};
  final Map<String, String> _listError = {};

  final Map<String, LoadState> _submissionsState = {};
  final Map<String, List<Submission>> _submissions = {};

  final Map<String, LoadState> _submissionDetailState = {};
  final Map<String, Submission> _submissionById = {};

  LoadState listStateFor(String courseId) =>
      _listState[courseId] ?? LoadState.initial;
  List<Assignment> assignmentsFor(String courseId) =>
      _assignments[courseId] ?? const [];
  String? listErrorFor(String courseId) => _listError[courseId];

  LoadState submissionsStateFor(String assignmentId) =>
      _submissionsState[assignmentId] ?? LoadState.initial;
  List<Submission> submissionsFor(String assignmentId) =>
      _submissions[assignmentId] ?? const [];

  LoadState submissionDetailState(String submissionId) =>
      _submissionDetailState[submissionId] ?? LoadState.initial;
  Submission? submission(String id) => _submissionById[id];

  Future<void> loadAssignments(String courseId,
      {bool force = false}) async {
    if (_listState[courseId] == LoadState.loading) return;
    if (!force && _listState[courseId] == LoadState.success) return;

    _listState[courseId] = LoadState.loading;
    _listError.remove(courseId);
    notifyListeners();

    try {
      _assignments[courseId] =
      await _service.listForCourseInstructor(courseId);
      _listState[courseId] = LoadState.success;
    } on ApiException catch (e) {
      _listError[courseId] = e.message;
      _listState[courseId] = LoadState.error;
    } catch (_) {
      _listError[courseId] = 'Could not load assignments.';
      _listState[courseId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<Assignment?> createAssignment({
    required String courseId,
    required String title,
    required String description,
    DateTime? dueDate,
    int maxPoints = 100,
    bool allowTextSubmission = true,
    bool allowFileSubmission = true,
    bool publish = false,
  }) async {
    try {
      final a = await _service.createAssignment(
        courseId: courseId,
        title: title,
        description: description,
        dueDate: dueDate,
        maxPoints: maxPoints,
        allowTextSubmission: allowTextSubmission,
        allowFileSubmission: allowFileSubmission,
        publish: publish,
      );
      _assignments[courseId] = [a, ...(_assignments[courseId] ?? [])];
      notifyListeners();
      return a;
    } on ApiException catch (e) {
      _listError[courseId] = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateAssignment({
    required String courseId,
    required String assignmentId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxPoints,
    bool? allowTextSubmission,
    bool? allowFileSubmission,
  }) async {
    try {
      final updated = await _service.updateAssignment(
        assignmentId: assignmentId,
        title: title,
        description: description,
        dueDate: dueDate,
        maxPoints: maxPoints,
        allowTextSubmission: allowTextSubmission,
        allowFileSubmission: allowFileSubmission,
      );
      _replace(courseId, updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> publishAssignment({
    required String courseId,
    required String assignmentId,
  }) async {
    try {
      final updated = await _service.publishAssignment(assignmentId);
      _replace(courseId, updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAssignment({
    required String courseId,
    required String assignmentId,
  }) async {
    try {
      await _service.deleteAssignment(assignmentId);
      _assignments[courseId] = (_assignments[courseId] ?? [])
          .where((a) => a.id != assignmentId)
          .toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _replace(String courseId, Assignment a) {
    _assignments[courseId] = (_assignments[courseId] ?? [])
        .map((x) => x.id == a.id ? a : x)
        .toList();
    notifyListeners();
  }

  // ---- Submissions ----
  Future<void> loadSubmissions(String assignmentId,
      {bool force = false}) async {
    if (_submissionsState[assignmentId] == LoadState.loading) return;
    if (!force && _submissionsState[assignmentId] == LoadState.success) {
      return;
    }

    _submissionsState[assignmentId] = LoadState.loading;
    notifyListeners();

    try {
      _submissions[assignmentId] =
      await _service.listSubmissions(assignmentId);
      _submissionsState[assignmentId] = LoadState.success;
    } catch (_) {
      _submissionsState[assignmentId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadSubmission(String submissionId,
      {bool force = false}) async {
    if (_submissionDetailState[submissionId] == LoadState.loading) return;
    if (!force && _submissionById[submissionId] != null) return;

    _submissionDetailState[submissionId] = LoadState.loading;
    notifyListeners();

    try {
      _submissionById[submissionId] =
      await _service.getSubmission(submissionId);
      _submissionDetailState[submissionId] = LoadState.success;
    } catch (_) {
      _submissionDetailState[submissionId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<bool> gradeSubmission({
    required String submissionId,
    required int score,
    required String feedback,
  }) async {
    try {
      final updated = await _service.gradeSubmission(
        submissionId: submissionId,
        score: score,
        feedback: feedback,
      );
      _submissionById[submissionId] = updated;
      _syncSubmissionInLists(updated);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestResubmission({
    required String submissionId,
    required String feedback,
  }) async {
    try {
      final updated = await _service.requestResubmission(
        submissionId: submissionId,
        feedback: feedback,
      );
      _submissionById[submissionId] = updated;
      _syncSubmissionInLists(updated);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _syncSubmissionInLists(Submission s) {
    for (final key in _submissions.keys.toList()) {
      _submissions[key] = (_submissions[key] ?? [])
          .map((x) => x.id == s.id ? s : x)
          .toList();
    }
  }
}