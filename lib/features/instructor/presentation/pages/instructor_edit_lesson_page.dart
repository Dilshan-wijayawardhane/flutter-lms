import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_lesson.dart';

class InstructorEditLessonPage extends StatefulWidget {
  const InstructorEditLessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<InstructorEditLessonPage> createState() =>
      _InstructorEditLessonPageState();
}

class _InstructorEditLessonPageState
    extends State<InstructorEditLessonPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  MockLesson? _lesson;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _lesson = _find();
    _titleCtrl.text = _lesson?.title ?? '';
    _contentCtrl.text = _lesson?.content ?? '';
    _durationCtrl.text = '${_lesson?.durationMinutes ?? 10}';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  MockLesson? _find() {
    for (final l in MockLessons.flutterFundamentals) {
      if (l.id == widget.lessonId) return l;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Lesson updated (mock).');
    Navigator.of(context).pop();
  }

  Future<void> _deleteMedia() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete media?',
      message:
      'This will remove the uploaded media. The lesson itself will '
          'remain.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    AppSnackbar.showInfo(
      context,
      'Delete media will call the backend in Phase 2.',
    );
  }

  Future<void> _deleteLesson() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete lesson?',
      message:
      'The lesson and its media will be permanently removed. This '
          'cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    AppSnackbar.showInfo(
      context,
      'Delete lesson will call the backend in Phase 2.',
    );
    Navigator.of(context).pop();
  }

  Future<void> _togglePublish() async {
    AppSnackbar.showInfo(
      context,
      'Publish/Unpublish will call the backend in Phase 2.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Lesson'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
            tooltip: 'Delete lesson',
            onPressed: _deleteLesson,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _header(lesson),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: _titleCtrl,
                label: 'Lesson title',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Lesson title'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _durationCtrl,
                label: 'Duration (minutes)',
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final parsed = int.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              if (lesson.type == LessonType.text) ...[
                AppTextField(
                  controller: _contentCtrl,
                  label: 'Lesson content',
                  maxLines: 12,
                  minLines: 6,
                  validator: (v) =>
                      Validators.minLength(v, 20, field: 'Content'),
                ),
              ] else ...[
                _mediaCard(lesson),
              ],

              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: lesson.status == LessonStatus.published
                    ? 'Unpublish'
                    : 'Publish Lesson',
                icon: lesson.status == LessonStatus.published
                    ? Icons.pause_circle_outline_rounded
                    : Icons.publish_rounded,
                onPressed: _togglePublish,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(MockLesson lesson) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(_typeIcon(lesson.type),
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.type.label,
                    style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text('Order ${lesson.order}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          if (lesson.status == LessonStatus.published)
            const AppStatusChip(status: AppStatus.published)
          else
            const AppStatusChip(status: AppStatus.draft),
        ],
      ),
    );
  }

  Widget _mediaCard(MockLesson lesson) {
    final isVideo = lesson.type == LessonType.video;
    final hasMedia = isVideo
        ? (lesson.videoUrl?.isNotEmpty ?? false)
        : (lesson.documentUrl?.isNotEmpty ?? false);

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
          Text(
            isVideo ? 'Video media' : 'Document media',
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasMedia
                ? (isVideo
                ? 'A video is attached to this lesson.'
                : 'Document: ${lesson.documentName ?? 'attached'}')
                : 'No media attached yet.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: hasMedia ? 'Replace media' : 'Upload media',
                  icon: Icons.cloud_upload_outlined,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.instructorLessonMedia,
                    arguments: lesson.id,
                  ),
                ),
              ),
              if (hasMedia) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _deleteMedia,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
                  tooltip: 'Delete media',
                ),
              ],
            ],
          ),
        ],
      ),
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