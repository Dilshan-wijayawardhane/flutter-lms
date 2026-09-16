import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../student/data/models/lesson.dart';
import '../../../student/providers/instructor_course_provider.dart';

class InstructorCreateLessonPage extends StatefulWidget {
  const InstructorCreateLessonPage({
    super.key,
    required this.courseId,
    required this.sectionId,
  });

  final String courseId;
  final String sectionId;

  @override
  State<InstructorCreateLessonPage> createState() =>
      _InstructorCreateLessonPageState();
}

class _InstructorCreateLessonPageState
    extends State<InstructorCreateLessonPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '10');

  LessonType _type = LessonType.text;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final p = context.read<InstructorCourseProvider>();
    final created = await p.createLesson(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      title: _titleCtrl.text.trim(),
      type: _type,
      durationMinutes: int.tryParse(_durationCtrl.text.trim()) ?? 10,
      content: _type == LessonType.text ? _contentCtrl.text.trim() : null,
      publish: publish,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (created != null) {
      AppSnackbar.showSuccess(
        context,
        publish ? 'Lesson published.' : 'Lesson saved as draft.',
      );
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        p.errorMessage ?? 'Could not create lesson.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Lesson')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('Lesson type', style: AppTextStyles.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              _typeSelector(),
              const SizedBox(height: AppSpacing.md),
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
              if (_type == LessonType.text)
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
                  child: Text(
                    'Media upload arrives with the upload phase. Save the '
                        'lesson as draft, then upload the media from the edit '
                        'screen.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save as Draft',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _saving ? null : () => _save(publish: false),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Save & Publish',
                icon: Icons.publish_rounded,
                onPressed: _saving ? null : () => _save(publish: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeSelector() {
    return Row(
      children: LessonType.values.map((t) {
        final active = t == _type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: t == LessonType.values.last ? 0 : AppSpacing.xs,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _type = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _typeIcon(t),
                      size: 20,
                      color: active
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.name.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: active
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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