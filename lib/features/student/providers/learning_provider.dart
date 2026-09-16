import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../data/models/lesson.dart';
import '../data/models/section.dart';
import '../data/services/course_service.dart';
import 'category_provider.dart';

/// Holds sections + lessons for one course. One instance per course is
/// ideal; for simplicity we keep a map keyed by courseId.
class LearningProvider extends ChangeNotifier {
  LearningProvider({CourseService? service})
      : _service = service ?? CourseService(ApiClient.instance);

  final CourseService _service;

  final Map<String, LoadState> _stateByCourse = {};
  final Map<String, List<CourseSection>> _sectionsByCourse = {};
  final Map<String, Map<String, List<Lesson>>> _lessonsBySection = {};
  final Map<String, String> _errorByCourse = {};

  LoadState stateFor(String courseId) =>
      _stateByCourse[courseId] ?? LoadState.initial;

  List<CourseSection> sectionsFor(String courseId) =>
      _sectionsByCourse[courseId] ?? const [];

  List<Lesson> lessonsFor(String sectionId) =>
      _lessonsBySection.values
          .expand((m) => m[sectionId] ?? const <Lesson>[])
          .toList();

  String? errorFor(String courseId) => _errorByCourse[courseId];

  /// Loads sections and (lazily) the lessons for each section.
  Future<void> loadCourse(String courseId, {bool force = false}) async {
    if (_stateByCourse[courseId] == LoadState.loading) return;
    if (!force && _sectionsByCourse[courseId] != null) return;

    _stateByCourse[courseId] = LoadState.loading;
    _errorByCourse.remove(courseId);
    notifyListeners();

    try {
      final sections = await _service.listSections(courseId);

      // Fetch lessons for each section in parallel.
      final lessonsMap = <String, List<Lesson>>{};
      await Future.wait(
        sections.map((s) async {
          try {
            final lessons = await _service.listLessons(s.id);
            lessonsMap[s.id] = lessons;
          } catch (_) {
            lessonsMap[s.id] = const [];
          }
        }),
      );

      _sectionsByCourse[courseId] = sections;
      _lessonsBySection[courseId] = lessonsMap;
      _stateByCourse[courseId] = LoadState.success;
    } on ApiException catch (e) {
      _errorByCourse[courseId] = e.message;
      _stateByCourse[courseId] = LoadState.error;
    } catch (_) {
      _errorByCourse[courseId] = 'Could not load curriculum.';
      _stateByCourse[courseId] = LoadState.error;
    }
    notifyListeners();
  }

  /// Marks a lesson completed locally after the backend confirms.
  void markLessonCompleted(String courseId, String lessonId) {
    final map = _lessonsBySection[courseId];
    if (map == null) return;
    for (final entry in map.entries) {
      final updated = entry.value.map((l) {
        if (l.id == lessonId) {
          return Lesson(
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
        }
        return l;
      }).toList();
      map[entry.key] = updated;
    }
    notifyListeners();
  }

  void clear() {
    _stateByCourse.clear();
    _sectionsByCourse.clear();
    _lessonsBySection.clear();
    _errorByCourse.clear();
    notifyListeners();
  }
}