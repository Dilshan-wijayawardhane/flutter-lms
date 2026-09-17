import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../../student/data/models/course.dart';
import '../../student/data/models/lesson.dart';
import '../../student/data/models/section.dart';
import '../../student/data/services/course_service.dart';

/// Wraps CourseService for the instructor role. Keeps a separate list of
/// "my courses" so it doesn't fight with the student browse state.
class InstructorCourseProvider extends ChangeNotifier {
  InstructorCourseProvider({CourseService? service})
      : _service = service ?? CourseService(ApiClient.instance);

  final CourseService _service;

  LoadState _listState = LoadState.initial;
  List<Course> _courses = const [];
  String? _error;

  final Map<String, LoadState> _sectionsState = {};
  final Map<String, List<CourseSection>> _sections = {};
  final Map<String, Map<String, List<Lesson>>> _lessons = {};

  LoadState get listState => _listState;
  List<Course> get courses => _courses;
  String? get errorMessage => _error;

  LoadState sectionsStateFor(String courseId) =>
      _sectionsState[courseId] ?? LoadState.initial;
  List<CourseSection> sectionsFor(String courseId) =>
      _sections[courseId] ?? const [];
  List<Lesson> lessonsFor(String courseId, String sectionId) =>
      _lessons[courseId]?[sectionId] ?? const [];

  Course? courseById(String id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<bool> uploadCourseThumbnail({
    required String courseId,
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final updated = await _service.uploadThumbnail(
        courseId: courseId,
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType,
        onSendProgress: onSendProgress,
      );
      _replace(updated);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCourseThumbnail(String courseId) async {
    try {
      await _service.deleteThumbnail(courseId);
      final existing = courseById(courseId);
      if (existing != null) {
        _replace(Course(
          id: existing.id,
          title: existing.title,
          description: existing.description,
          instructorId: existing.instructorId,
          instructorName: existing.instructorName,
          categoryId: existing.categoryId,
          categoryName: existing.categoryName,
          status: existing.status,
          level: existing.level,
          shortDescription: existing.shortDescription,
          thumbnailUrl: null,
          price: existing.price,
          rating: existing.rating,
          ratingCount: existing.ratingCount,
          learnerCount: existing.learnerCount,
          sectionCount: existing.sectionCount,
          lessonCount: existing.lessonCount,
          totalDurationMinutes: existing.totalDurationMinutes,
          isEnrolled: existing.isEnrolled,
          progressPercent: existing.progressPercent,
          createdAt: existing.createdAt,
          updatedAt: existing.updatedAt,
        ));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> uploadLessonVideo({
    required String courseId,
    required String sectionId,
    required String lessonId,
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final updated = await _service.uploadLessonVideo(
        lessonId: lessonId,
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType,
        onSendProgress: onSendProgress,
      );
      final list = _lessons[courseId]?[sectionId] ?? [];
      _lessons[courseId]?[sectionId] = list
          .map((l) => l.id == lessonId ? updated : l)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> uploadLessonDocument({
    required String courseId,
    required String sectionId,
    required String lessonId,
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final updated = await _service.uploadLessonDocument(
        lessonId: lessonId,
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType,
        onSendProgress: onSendProgress,
      );
      final list = _lessons[courseId]?[sectionId] ?? [];
      _lessons[courseId]?[sectionId] = list
          .map((l) => l.id == lessonId ? updated : l)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteLessonMedia({
    required String courseId,
    required String sectionId,
    required String lessonId,
  }) async {
    try {
      await _service.deleteLessonMedia(lessonId);
      final list = _lessons[courseId]?[sectionId] ?? [];
      _lessons[courseId]?[sectionId] = list
          .map((l) => l.id == lessonId
          ? Lesson(
        id: l.id,
        sectionId: l.sectionId,
        courseId: l.courseId,
        title: l.title,
        type: l.type,
        status: l.status,
        order: l.order,
        durationMinutes: l.durationMinutes,
        content: l.content,
        videoUrl: null,
        documentUrl: null,
        documentName: null,
        isCompleted: l.isCompleted,
        isLocked: l.isLocked,
      )
          : l)
          .toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadMyCourses({bool force = false}) async {
    if (_listState == LoadState.loading) return;
    if (!force && _listState == LoadState.success) return;

    _listState = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _courses = await _service.listInstructorCourses();
      _listState = LoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _listState = LoadState.error;
    } catch (_) {
      _error = 'Could not load your courses.';
      _listState = LoadState.error;
    }
    notifyListeners();
  }

  Future<Course?> createCourse({
    required String title,
    required String description,
    String? shortDescription,
    required String categoryId,
    required CourseLevel level,
    double price = 0,
    bool publish = false,
  }) async {
    try {
      final c = await _service.createCourse(
        title: title,
        description: description,
        shortDescription: shortDescription,
        categoryId: categoryId,
        level: level,
        price: price,
        publish: publish,
      );
      _courses = [c, ..._courses];
      _listState = LoadState.success;
      notifyListeners();
      return c;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _error = 'Could not create course.';
      notifyListeners();
      return null;
    }
  }

  Future<Course?> updateCourse({
    required String courseId,
    String? title,
    String? description,
    String? shortDescription,
    String? categoryId,
    CourseLevel? level,
    double? price,
  }) async {
    try {
      final c = await _service.updateCourse(
        courseId: courseId,
        title: title,
        description: description,
        shortDescription: shortDescription,
        categoryId: categoryId,
        level: level,
        price: price,
      );
      _replace(c);
      return c;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> publishCourse(String id) async {
    try {
      _replace(await _service.publishCourse(id));
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> archiveCourse(String id) async {
    try {
      _replace(await _service.archiveCourse(id));
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCourse(String id) async {
    try {
      await _service.deleteCourse(id);
      _courses = _courses.where((c) => c.id != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---- Sections ----
  Future<void> loadSections(String courseId, {bool force = false}) async {
    if (_sectionsState[courseId] == LoadState.loading) return;
    if (!force && _sections[courseId] != null) return;

    _sectionsState[courseId] = LoadState.loading;
    notifyListeners();

    try {
      final sections = await _service.listSections(courseId);

      final lessonsMap = <String, List<Lesson>>{};
      await Future.wait(
        sections.map((s) async {
          try {
            lessonsMap[s.id] = await _service.listLessons(s.id);
          } catch (_) {
            lessonsMap[s.id] = const [];
          }
        }),
      );

      _sections[courseId] = sections;
      _lessons[courseId] = lessonsMap;
      _sectionsState[courseId] = LoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _sectionsState[courseId] = LoadState.error;
    } catch (_) {
      _sectionsState[courseId] = LoadState.error;
    }
    notifyListeners();
  }

  Future<CourseSection?> createSection({
    required String courseId,
    required String title,
    String? description,
  }) async {
    try {
      final s = await _service.createSection(
        courseId: courseId,
        title: title,
        description: description,
      );
      _sections[courseId] = [...(_sections[courseId] ?? []), s];
      _lessons[courseId] ??= {};
      _lessons[courseId]![s.id] = [];
      _sectionsState[courseId] = LoadState.success;
      notifyListeners();
      return s;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateSection({
    required String courseId,
    required String sectionId,
    String? title,
    String? description,
  }) async {
    try {
      final updated = await _service.updateSection(
        sectionId: sectionId,
        title: title,
        description: description,
      );
      final list = _sections[courseId] ?? [];
      _sections[courseId] = list
          .map((s) => s.id == sectionId ? updated : s)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSection({
    required String courseId,
    required String sectionId,
  }) async {
    try {
      await _service.deleteSection(sectionId);
      _sections[courseId] =
          (_sections[courseId] ?? []).where((s) => s.id != sectionId).toList();
      _lessons[courseId]?.remove(sectionId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reorderSections({
    required String courseId,
    required List<String> orderedIds,
  }) async {
    try {
      await _service.reorderSections(
        courseId: courseId,
        sectionIdsInOrder: orderedIds,
      );
      final list = _sections[courseId] ?? [];
      final byId = {for (final s in list) s.id: s};
      _sections[courseId] = [
        for (var i = 0; i < orderedIds.length; i++)
          if (byId[orderedIds[i]] != null) byId[orderedIds[i]]!,
      ];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---- Lessons ----
  Future<Lesson?> createLesson({
    required String courseId,
    required String sectionId,
    required String title,
    required LessonType type,
    required int durationMinutes,
    String? content,
    bool publish = false,
  }) async {
    try {
      final l = await _service.createLesson(
        sectionId: sectionId,
        title: title,
        type: type,
        durationMinutes: durationMinutes,
        content: content,
        publish: publish,
      );
      _lessons[courseId] ??= {};
      _lessons[courseId]![sectionId] = [
        ...(_lessons[courseId]![sectionId] ?? []),
        l,
      ];
      notifyListeners();
      return l;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateLesson({
    required String courseId,
    required String sectionId,
    required String lessonId,
    String? title,
    int? durationMinutes,
    String? content,
  }) async {
    try {
      final updated = await _service.updateLesson(
        lessonId: lessonId,
        title: title,
        durationMinutes: durationMinutes,
        content: content,
      );
      final list = _lessons[courseId]?[sectionId] ?? [];
      _lessons[courseId]?[sectionId] = list
          .map((l) => l.id == lessonId ? updated : l)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> publishLesson({
    required String courseId,
    required String sectionId,
    required String lessonId,
  }) async {
    try {
      final updated = await _service.publishLesson(lessonId);
      final list = _lessons[courseId]?[sectionId] ?? [];
      _lessons[courseId]?[sectionId] = list
          .map((l) => l.id == lessonId ? updated : l)
          .toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteLesson({
    required String courseId,
    required String sectionId,
    required String lessonId,
  }) async {
    try {
      await _service.deleteLesson(lessonId);
      final list = _lessons[courseId]?[sectionId] ?? [];
      _lessons[courseId]?[sectionId] =
          list.where((l) => l.id != lessonId).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  void _replace(Course c) {
    _courses = _courses.map((x) => x.id == c.id ? c : x).toList();
    notifyListeners();
  }
}