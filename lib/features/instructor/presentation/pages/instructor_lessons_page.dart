import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_lesson.dart';
import '../../../../mock_data/models/mock_section.dart';
import '../widgets/lesson_row.dart';

class InstructorLessonsPage extends StatefulWidget {
  const InstructorLessonsPage({super.key, required this.sectionId});

  final String sectionId;

  @override
  State<InstructorLessonsPage> createState() =>
      _InstructorLessonsPageState();
}

class _InstructorLessonsPageState extends State<InstructorLessonsPage> {
  MockSection? _section;
  late List<MockLesson> _lessons;

  @override
  void initState() {
    super.initState();
    _section = _findSection();
    _lessons = List.of(MockLessons.bySection(widget.sectionId));
  }

  MockSection? _findSection() {
    for (final list in [
      MockSections.flutterFundamentals,
      MockSections.advancedFlutter,
    ]) {
      for (final s in list) {
        if (s.id == widget.sectionId) return s;
      }
    }
    return null;
  }

  Future<void> _delete(MockLesson lesson) async {
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
    setState(() => _lessons.removeWhere((l) => l.id == lesson.id));
    AppSnackbar.showSuccess(context, 'Lesson deleted (mock).');
  }

  @override
  Widget build(BuildContext context) {
    final section = _section;
    if (section == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Section not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          section.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: _lessons.isEmpty
            ? AppEmptyState(
          icon: Icons.play_lesson_outlined,
          title: 'No lessons yet',
          message:
          'Add your first lesson to this section. You can create '
              'TEXT, VIDEO, or DOCUMENT lessons.',
          actionLabel: 'Create Lesson',
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.instructorCreateLesson,
            arguments: widget.sectionId,
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _lessons.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final l = _lessons[i];
            return InstructorLessonRow(
              lesson: l,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditLesson,
                arguments: l.id,
              ),
              onEdit: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditLesson,
                arguments: l.id,
              ),
              onDelete: () => _delete(l),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateLesson,
          arguments: widget.sectionId,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Lesson'),
      ),
    );
  }
}