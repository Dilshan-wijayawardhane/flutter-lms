import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../data/models/assignment.dart';
import '../data/models/submission.dart';
import '../data/services/assignment_service.dart';

class AssignmentProvider extends ChangeNotifier {
  AssignmentProvider({AssignmentService? service})
      : _service = service ?? AssignmentService(ApiClient.instance);

  final AssignmentService _service;

  LoadState _listState = LoadState.initial;
  List<Assignment> _assignments = const [];
  String? _listError;

  final Map<String, LoadState> _detailState = {};
  final Map<String, Assignment> _details = {};
  final Map<String, Submission?> _mySubmissions = {};
  final Map<String, String> _detailError = {};

  // ---- Getters ----
  LoadState get listState => _listState;
  List<Assignment> get assignments => _assignments;
  String? get listError => _listError;

  LoadState detailStateFor(String assignmentId) =>
      _detailState[assignmentId] ?? LoadState.initial;
  Assignment? assignmentById(String id) => _details[id];
  Submission? submissionFor(String assignmentId) =>
      _mySubmissions[assignmentId];
  String? detailErrorFor(String id) => _detailError[id];

  // ---- List ----
  Future<void> loadMine({bool force = false}) async {
    if (_listState == LoadState.loading) return;
    if (!force && _listState == LoadState.success) return;

    _listState = LoadState.loading;
    _listError = null;
    notifyListeners();

    try {
      _assignments = await _service.listMine();
      _listState = LoadState.success;
    } on ApiException catch (e) {
      _listError = e.message;
      _listState = LoadState.error;
    } catch (_) {
      _listError = 'Could not load assignments.';
      _listState = LoadState.error;
    }
    notifyListeners();
  }

  // ---- Details + my submission ----
  Future<void> loadDetails(String id, {bool force = false}) async {
    if (_detailState[id] == LoadState.loading) return;
    if (!force && _detailState[id] == LoadState.success) return;

    _detailState[id] = LoadState.loading;
    _detailError.remove(id);
    notifyListeners();

    try {
      final a = await _service.getAssignment(id);
      final s = await _service.getMySubmission(id);
      _details[id] = a;
      _mySubmissions[id] = s;
      _detailState[id] = LoadState.success;
    } on ApiException catch (e) {
      _detailError[id] = e.message;
      _detailState[id] = LoadState.error;
    } catch (_) {
      _detailError[id] = 'Could not load assignment.';
      _detailState[id] = LoadState.error;
    }
    notifyListeners();
  }

  Future<Submission?> submitText({
    required String assignmentId,
    required String text,
  }) async {
    try {
      final s = await _service.submitText(
        assignmentId: assignmentId,
        text: text,
      );
      _mySubmissions[assignmentId] = s;
      notifyListeners();
      return s;
    } on ApiException catch (e) {
      _detailError[assignmentId] = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Submission?> submitFile({
    required String assignmentId,
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final s = await _service.submitFile(
        assignmentId: assignmentId,
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType,
        onSendProgress: onSendProgress,
      );
      _mySubmissions[assignmentId] = s;
      notifyListeners();
      return s;
    } on ApiException catch (e) {
      _detailError[assignmentId] = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }
}