import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../data/models/lesson.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/lesson_provider.dart';

class StudentLessonPage extends StatefulWidget {
  const StudentLessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<StudentLessonPage> createState() => _StudentLessonPageState();
}

class _StudentLessonPageState extends State<StudentLessonPage> {
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().load(widget.lessonId);
      context.read<EnrollmentProvider>().startLesson(widget.lessonId);
    });
  }

  Future<void> _toggleComplete(Lesson lesson) async {
    if (lesson.isCompleted) {
      AppSnackbar.showInfo(context, 'Lesson already completed.');
      return;
    }
    setState(() => _completing = true);

    final enroll = context.read<EnrollmentProvider>();
    final lessonProv = context.read<LessonProvider>();
    final learning = context.read<LearningProvider>();

    final ok = await enroll.completeLesson(lesson.id);

    if (!mounted) return;
    setState(() => _completing = false);

    if (ok) {
      lessonProv.markCompleted(lesson.id);
      learning.markLessonCompleted(lesson.courseId, lesson.id);
      AppSnackbar.showSuccess(context, 'Lesson marked as complete');
    } else {
      AppSnackbar.showError(
        context,
        enroll.errorMessage ?? 'Could not complete the lesson.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonProvider>();
    final state = provider.stateFor(widget.lessonId);
    final lesson = provider.lessonById(widget.lessonId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          lesson?.title ?? 'Lesson',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(state as LoadState, lesson, provider),
      ),
    );
  }

  Widget _buildBody(
      LoadState state,
      Lesson? lesson,
      LessonProvider provider,
      ) {
    if (state == LoadState.loading && lesson == null) {
      return const AppLoading(message: 'Loading lesson…');
    }
    if (state == LoadState.error && lesson == null) {
      return AppErrorState(
        title: 'Could not load lesson',
        message: provider.errorFor(widget.lessonId) ?? 'Please try again.',
        onRetry: () =>
            provider.load(widget.lessonId, force: true),
      );
    }
    if (lesson == null) {
      return const Center(child: Text('Lesson not found'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _typeHeader(lesson),
        const SizedBox(height: AppSpacing.md),
        _content(lesson),
        const SizedBox(height: AppSpacing.xl),
        _bottomActions(lesson),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _typeHeader(Lesson lesson) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_typeIcon(lesson.type),
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                lesson.type.name.toUpperCase(),
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(Formatters.duration(lesson.durationMinutes),
            style: AppTextStyles.caption),
        const Spacer(),
        if (lesson.isCompleted)
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 20),
      ],
    );
  }

  Widget _content(Lesson lesson) {
    switch (lesson.type) {
      case LessonType.text:
        return _textContent(lesson);
      case LessonType.video:
        return _videoContent(lesson);
      case LessonType.document:
        return _documentContent(lesson);
    }
  }

  Widget _textContent(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        lesson.content ?? 'No content available.',
        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
      ),
    );
  }

  Widget _videoContent(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius:
              BorderRadius.circular(AppSpacing.radiusMd),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                    child: Text(
                      lesson.videoUrl ?? 'Video URL unavailable',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'Video playback will be added in a later phase. The video URL '
                'is available above.',
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _documentContent(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.documentName ?? 'Document',
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.documentUrl ?? 'URL unavailable',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton.secondary(
          label: 'Open document',
          icon: Icons.open_in_new_rounded,
          onPressed: () {
            AppSnackbar.showInfo(
              context,
              'Document viewer arrives in a later phase.',
            );
          },
        ),
      ],
    );
  }

  Widget _bottomActions(Lesson lesson) {
    return AppButton.primary(
      label: lesson.isCompleted ? 'Completed' : 'Mark as Complete',
      icon: lesson.isCompleted
          ? Icons.check_circle_rounded
          : Icons.check_circle_outline_rounded,
      isLoading: _completing,
      onPressed: _completing ? null : () => _toggleComplete(lesson),
    );
  }

  IconData _typeIcon(LessonType t) {
    switch (t) {
      case LessonType.text:
        return Icons.article_outlined;
      case LessonType.video:
        return Icons.play_circle_outline_rounded;
      case LessonType.document:
        return Icons.description_outlined;
    }
  }
}