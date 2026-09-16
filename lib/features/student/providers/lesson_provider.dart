import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../data/models/lesson.dart';
import '../data/services/course_service.dart';
import 'category_provider.dart';

class LessonProvider extends ChangeNotifier {
  LessonProvider({CourseService? service})
      : _service = service ?? CourseService(ApiClient.instance);

  final CourseService _service;

  final Map<String, LoadState> _stateByLesson = {};
  final Map<String, Lesson> _lessons = {};
  final Map<String, String> _errors = {};

  LoadState stateFor(String lessonId) =>
      _stateByLesson[lessonId] ?? LoadState.initial;
  Lesson? lessonById(String lessonId) => _lessons[lessonId];
  String? errorFor(String lessonId) => _errors[lessonId];

  Future<void> load(String lessonId, {bool force = false}) async {
    if (_stateByLesson[lessonId] == LoadState.loading) return;
    if (!force && _lessons[lessonId] != null) return;

    _stateByLesson[lessonId] = LoadState.loading;
    _errors.remove(lessonId);
    notifyListeners();

    try {
      final l = await _service.getLesson(lessonId);
      _lessons[lessonId] = l;
      _stateByLesson[lessonId] = LoadState.success;
    } on ApiException catch (e) {
      _errors[lessonId] = e.message;
      _stateByLesson[lessonId] = LoadState.error;
    } catch (_) {
      _errors[lessonId] = 'Could not load lesson.';
      _stateByLesson[lessonId] = LoadState.error;
    }
    notifyListeners();
  }

  void markCompleted(String lessonId) {
    final l = _lessons[lessonId];
    if (l == null) return;
    _lessons[lessonId] = Lesson(
      id: l.id,
      sectionId: l.sectionId,
      courseId: l.courseId,
      title: l.title,
      type: l.type,
      status: l.status,
      order: l.order,
      durationMinutes: l.durationMinutes,
      content: l.content,
      videoUrl: l.videoUrl,
      documentUrl: l.documentUrl,
      documentName: l.documentName,
      isCompleted: true,
      isLocked: l.isLocked,
    );
    notifyListeners();
  }
}