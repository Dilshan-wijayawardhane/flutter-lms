import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_course.dart';
import '../../../../mock_data/models/mock_section.dart';
import '../widgets/section_card.dart';

class InstructorSectionsPage extends StatefulWidget {
  const InstructorSectionsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorSectionsPage> createState() =>
      _InstructorSectionsPageState();
}

class _InstructorSectionsPageState
    extends State<InstructorSectionsPage> {
  MockCourse? _course;
  late List<MockSection> _sections;

  @override
  void initState() {
    super.initState();
    _course = _find(widget.courseId);
    _sections = List.of(MockSections.byCourse(widget.courseId));
  }

  MockCourse? _find(String id) {
    for (final c in MockCourses.all) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> _delete(MockSection s) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete section?',
      message:
      'All lessons in "${s.title}" will be removed. This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _sections.removeWhere((x) => x.id == s.id);
    });
    AppSnackbar.showSuccess(context, 'Section deleted (mock).');
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;
    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Course not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sections & Lessons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert_rounded),
            tooltip: 'Reorder',
            onPressed: _sections.length < 2
                ? null
                : () => Navigator.of(context).pushNamed(
              AppRoutes.instructorReorderSections,
              arguments: widget.courseId,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _sections.isEmpty
            ? AppEmptyState(
          icon: Icons.list_alt_rounded,
          title: 'No sections yet',
          message:
          'Add your first section to start building this course.',
          actionLabel: 'Create Section',
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.instructorCreateSection,
            arguments: widget.courseId,
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _sections.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final s = _sections[i];
            return SectionCard(
              section: s,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorLessons,
                arguments: s.id,
              ),
              onEdit: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditSection,
                arguments: s.id,
              ),
              onDelete: () => _delete(s),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateSection,
          arguments: widget.courseId,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Section'),
      ),
    );
  }
}