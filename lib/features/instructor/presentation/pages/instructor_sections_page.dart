import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/data/models/section.dart';
import '../../../student/providers/instructor_course_provider.dart';
import '../widgets/section_card.dart';

class InstructorSectionsPage extends StatefulWidget {
  const InstructorSectionsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorSectionsPage> createState() =>
      _InstructorSectionsPageState();
}

class _InstructorSectionsPageState extends State<InstructorSectionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorCourseProvider>().loadSections(
        widget.courseId,
      );
    });
  }

  Future<void> _delete(CourseSection s) async {
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

    final ok = await context
        .read<InstructorCourseProvider>()
        .deleteSection(courseId: widget.courseId, sectionId: s.id);

    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Section deleted.' : 'Could not delete section.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstructorCourseProvider>();
    final state = provider.sectionsStateFor(widget.courseId);
    final sections = provider.sectionsFor(widget.courseId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sections & Lessons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert_rounded),
            tooltip: 'Reorder',
            onPressed: sections.length < 2
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
        child: state == LoadState.loading && sections.isEmpty
            ? const AppLoading(message: 'Loading sections…')
            : state == LoadState.error && sections.isEmpty
            ? AppErrorState(
          title: 'Could not load sections',
          message: provider.errorMessage ?? 'Please try again.',
          onRetry: () => provider.loadSections(
            widget.courseId,
            force: true,
          ),
        )
            : sections.isEmpty
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
            : RefreshIndicator(
          onRefresh: () => provider.loadSections(
            widget.courseId,
            force: true,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sections.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final s = sections[i];
              return SectionCard(
                section: s,
                onTap: () => Navigator.of(context)
                    .pushNamed(
                  AppRoutes.instructorLessons,
                  arguments: {
                    'courseId': widget.courseId,
                    'sectionId': s.id,
                  },
                ),
                onEdit: () => Navigator.of(context)
                    .pushNamed(
                  AppRoutes.instructorEditSection,
                  arguments: {
                    'courseId': widget.courseId,
                    'sectionId': s.id,
                  },
                ),
                onDelete: () => _delete(s),
              );
            },
          ),
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