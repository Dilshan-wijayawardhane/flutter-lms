import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/data/models/lesson.dart';
import '../../../student/providers/instructor_course_provider.dart';
import '../widgets/lesson_row.dart';

class InstructorLessonsPage extends StatefulWidget {
  const InstructorLessonsPage({
    super.key,
    required this.courseId,
    required this.sectionId,
  });

  final String courseId;
  final String sectionId;

  @override
  State<InstructorLessonsPage> createState() =>
      _InstructorLessonsPageState();
}

class _InstructorLessonsPageState extends State<InstructorLessonsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InstructorCourseProvider>()
          .loadSections(widget.courseId);
    });
  }

  Future<void> _delete(Lesson lesson) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete lesson?',
      message:
      'The lesson and any uploaded media will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    final ok = await context.read<InstructorCourseProvider>().deleteLesson(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: lesson.id,
    );
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Lesson deleted.' : 'Could not delete.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InstructorCourseProvider>();
    final state = p.sectionsStateFor(widget.courseId);
    final lessons = p.lessonsFor(widget.courseId, widget.sectionId);

    final section = p
        .sectionsFor(widget.courseId)
        .where((s) => s.id == widget.sectionId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          section?.title ?? 'Lessons',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: state == LoadState.loading && lessons.isEmpty
            ? const AppLoading(message: 'Loading lessons…')
            : lessons.isEmpty
            ? AppEmptyState(
          icon: Icons.play_lesson_outlined,
          title: 'No lessons yet',
          message:
          'Add your first lesson. TEXT, VIDEO, and DOCUMENT types are supported.',
          actionLabel: 'Create Lesson',
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.instructorCreateLesson,
            arguments: {
              'courseId': widget.courseId,
              'sectionId': widget.sectionId,
            },
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: lessons.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final l = lessons[i];
            return InstructorLessonRow(
              lesson: l,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditLesson,
                arguments: {
                  'courseId': widget.courseId,
                  'sectionId': widget.sectionId,
                  'lessonId': l.id,
                },
              ),
              onEdit: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditLesson,
                arguments: {
                  'courseId': widget.courseId,
                  'sectionId': widget.sectionId,
                  'lessonId': l.id,
                },
              ),
              onDelete: () => _delete(l),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateLesson,
          arguments: {
            'courseId': widget.courseId,
            'sectionId': widget.sectionId,
          },
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Lesson'),
      ),
    );
  }
}