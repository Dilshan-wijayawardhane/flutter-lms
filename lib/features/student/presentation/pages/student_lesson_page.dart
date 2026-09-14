import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_lesson.dart';

class StudentLessonPage extends StatefulWidget {
  const StudentLessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<StudentLessonPage> createState() => _StudentLessonPageState();
}

class _StudentLessonPageState extends State<StudentLessonPage> {
  late bool _completed;

  @override
  void initState() {
    super.initState();
    final lesson = _findLesson(widget.lessonId);
    _completed = lesson?.isCompleted ?? false;
  }

  MockLesson? _findLesson(String id) {
    for (final l in MockLessons.flutterFundamentals) {
      if (l.id == id) return l;
    }
    return null;
  }

  void _toggleComplete() {
    setState(() => _completed = !_completed);
    AppSnackbar.showSuccess(
      context,
      _completed ? 'Lesson marked as complete (mock)' : 'Marked incomplete',
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _findLesson(widget.lessonId);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _typeHeader(lesson),
            const SizedBox(height: AppSpacing.md),
            _content(lesson),
            const SizedBox(height: AppSpacing.xl),
            _bottomActions(lesson),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _typeHeader(MockLesson lesson) {
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
                lesson.type.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          Formatters.duration(lesson.durationMinutes),
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _content(MockLesson lesson) {
    switch (lesson.type) {
      case LessonType.text:
        return _textContent(lesson);
      case LessonType.video:
        return _videoContent(lesson);
      case LessonType.document:
        return _documentContent(lesson);
    }
  }

  Widget _textContent(MockLesson lesson) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        lesson.content ?? 'No content.',
        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
      ),
    );
  }

  Widget _videoContent(MockLesson lesson) {
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
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Video placeholder · Phase 2 will play real media',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
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
            'Video content is not streamed in this phase. In the backend '
                'integration phase, this area will host the media player '
                'connected to the video URL provided by the backend.',
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _documentContent(MockLesson lesson) {
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
                      'PDF · Tap below to preview',
                      style: AppTextStyles.caption,
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
              'Document preview arrives with backend integration.',
            );
          },
        ),
      ],
    );
  }

  Widget _bottomActions(MockLesson lesson) {
    return Row(
      children: [
        Expanded(
          child: AppButton.secondary(
            label: _completed ? 'Completed' : 'Mark as Complete',
            icon: _completed
                ? Icons.check_circle_rounded
                : Icons.check_circle_outline_rounded,
            onPressed: _toggleComplete,
          ),
        ),
      ],
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