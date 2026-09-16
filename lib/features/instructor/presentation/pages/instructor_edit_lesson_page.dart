import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../student/data/models/lesson.dart';
import '../../../student/providers/instructor_course_provider.dart';

class InstructorEditLessonPage extends StatefulWidget {
  const InstructorEditLessonPage({
    super.key,
    required this.courseId,
    required this.sectionId,
    required this.lessonId,
  });

  final String courseId;
  final String sectionId;
  final String lessonId;

  @override
  State<InstructorEditLessonPage> createState() =>
      _InstructorEditLessonPageState();
}

class _InstructorEditLessonPageState
    extends State<InstructorEditLessonPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _durationCtrl;

  Lesson? _lesson;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<InstructorCourseProvider>();
    for (final l in p.lessonsFor(widget.courseId, widget.sectionId)) {
      if (l.id == widget.lessonId) {
        _lesson = l;
        break;
      }
    }
    _titleCtrl = TextEditingController(text: _lesson?.title ?? '');
    _contentCtrl = TextEditingController(text: _lesson?.content ?? '');
    _durationCtrl =
        TextEditingController(text: '${_lesson?.durationMinutes ?? 10}');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<InstructorCourseProvider>();
    final ok = await p.updateLesson(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: widget.lessonId,
      title: _titleCtrl.text.trim(),
      durationMinutes: int.tryParse(_durationCtrl.text.trim()),
      content: _lesson?.type == LessonType.text
          ? _contentCtrl.text.trim()
          : null,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      AppSnackbar.showSuccess(context, 'Lesson updated.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        p.errorMessage ?? 'Could not update lesson.',
      );
    }
  }

  Future<void> _togglePublish() async {
    final l = _lesson;
    if (l == null) return;
    final p = context.read<InstructorCourseProvider>();
    final ok = await p.publishLesson(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: l.id,
    );
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Lesson published.' : 'Could not publish.',
    );
  }

  Future<void> _delete() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete lesson?',
      message: 'The lesson and its media will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    final p = context.read<InstructorCourseProvider>();
    final ok = await p.deleteLesson(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: widget.lessonId,
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Lesson deleted.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        p.errorMessage ?? 'Could not delete lesson.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = _lesson;
    if (l == null) {
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
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger),
            tooltip: 'Delete',
            onPressed: _delete,
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
              _headerCard(l),
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
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid duration';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (l.type == LessonType.text)
                AppTextField(
                  controller: _contentCtrl,
                  label: 'Lesson content',
                  maxLines: 12,
                  minLines: 6,
                  validator: (v) =>
                      Validators.minLength(v, 20, field: 'Content'),
                )
              else
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Media', style: AppTextStyles.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l.type == LessonType.video
                            ? 'Video URL: ${l.videoUrl ?? "none"}'
                            : 'Document: ${l.documentName ?? "none"}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (l.status == LessonStatus.draft)
                AppButton.secondary(
                  label: 'Publish Lesson',
                  icon: Icons.publish_rounded,
                  onPressed: _togglePublish,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard(Lesson l) {
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
            child: Icon(_typeIcon(l.type),
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.type.name.toUpperCase(),
                    style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text('Order ${l.order}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          if (l.status == LessonStatus.published)
            const AppStatusChip(status: AppStatus.published)
          else
            const AppStatusChip(status: AppStatus.draft),
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