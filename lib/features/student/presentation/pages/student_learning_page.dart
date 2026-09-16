import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/load_state.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/enrollment.dart';
import '../../data/models/lesson.dart';
import '../../providers/enrollment_provider.dart' hide LoadState;
import '../../providers/learning_provider.dart';

class StudentLearningPage extends StatefulWidget {
  const StudentLearningPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<StudentLearningPage> createState() =>
      _StudentLearningPageState();
}

class _StudentLearningPageState extends State<StudentLearningPage> {
  int _expandedSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadCourse(widget.courseId);
      final enroll = context.read<EnrollmentProvider>();
      if (enroll.state != LoadState.success) enroll.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final enrollments = context.watch<EnrollmentProvider>();

    final state = learning.stateFor(widget.courseId);
    final sections = learning.sectionsFor(widget.courseId);
    final enrollment = _findEnrollment(enrollments.enrollments);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Course')),
      body: SafeArea(
        top: false,
        child: _buildBody(state as LoadState, sections, learning, enrollment),
      ),
    );
  }

  Enrollment? _findEnrollment(List<Enrollment> list) {
    for (final e in list) {
      if (e.courseId == widget.courseId) return e;
    }
    return null;
  }

  Widget _buildBody(
      LoadState state,
      List sections,
      LearningProvider learning,
      Enrollment? enrollment,
      ) {
    if (state == LoadState.loading && sections.isEmpty) {
      return const AppLoading(message: 'Loading curriculum…');
    }
    if (state == LoadState.error && sections.isEmpty) {
      return AppErrorState(
        title: 'Could not load curriculum',
        message: learning.errorFor(widget.courseId) ?? 'Please try again.',
        onRetry: () =>
            learning.loadCourse(widget.courseId, force: true),
      );
    }
    if (sections.isEmpty) {
      return const AppEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'No sections yet',
        message: 'The instructor has not published any sections.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          learning.loadCourse(widget.courseId, force: true),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (enrollment != null) _progressHeader(enrollment),
          const SizedBox(height: AppSpacing.lg),
          Text('Curriculum', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(
            sections.length,
                (i) => _sectionBlock(sections[i], i, learning),
          ),
        ],
      ),
    );
  }

  Widget _progressHeader(Enrollment e) {
    final value = (e.progressPercent / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Your progress',
                    style: AppTextStyles.labelLarge),
              ),
              Text(
                '${e.progressPercent}%',
                style: AppTextStyles.headingSmall
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
              const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${e.completedLessonCount} of ${e.totalLessonCount} lessons',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _sectionBlock(dynamic section, int index, LearningProvider learning) {
    final lessons = learning.lessonsFor(section.id);
    final expanded = _expandedSectionIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: () => setState(
                  () => _expandedSectionIndex = expanded ? -1 : index,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${section.title}',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${lessons.length} lessons',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                children: List.generate(lessons.length, (i) {
                  final lesson = lessons[i];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.xs,
                    ),
                    child: _lessonTile(lesson, i + 1),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _lessonTile(Lesson lesson, int index) {
    final locked = lesson.isLocked;
    final completed = lesson.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        onTap: locked
            ? null
            : () => Navigator.of(context).pushNamed(
          AppRoutes.studentLesson,
          arguments: lesson.id,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: locked
                      ? AppColors.surfaceVariant
                      : completed
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.primarySurface,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  '$index',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: locked
                        ? AppColors.textTertiary
                        : completed
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: locked
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lesson.type.name.toUpperCase()} · ${Formatters.duration(lesson.durationMinutes)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (locked)
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                )
              else if (completed)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.success,
                )
              else
                const Icon(
                  Icons.play_circle_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}