import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../mock_data/models/mock_lesson.dart';

class InstructorCreateLessonPage extends StatefulWidget {
  const InstructorCreateLessonPage({super.key, required this.sectionId});

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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(
      context,
      publish ? 'Lesson published (mock).' : 'Lesson saved as draft (mock).',
    );
    Navigator.of(context).pop();
  }

  void _openMediaPage() {
    Navigator.of(context).pushNamed(
      AppRoutes.instructorLessonMedia,
      arguments: 'new',
    );
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
                hint: 'e.g., Installing the SDK',
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

              if (_type == LessonType.text) ...[
                AppTextField(
                  controller: _contentCtrl,
                  label: 'Lesson content',
                  hint:
                  'Write the lesson body. Markdown support arrives with '
                      'backend integration.',
                  maxLines: 12,
                  minLines: 6,
                  validator: (v) =>
                      Validators.minLength(v, 20, field: 'Content'),
                ),
              ] else if (_type == LessonType.video) ...[
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
                      Text(
                        'Video media',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Upload the video after saving the lesson. In this '
                            'phase, uploads are UI-only and connect to the '
                            'backend in the integration phase.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton.secondary(
                        label: 'Manage media',
                        icon: Icons.cloud_upload_outlined,
                        onPressed: _openMediaPage,
                      ),
                    ],
                  ),
                ),
              ] else ...[
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
                      Text(
                        'Document media',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Attach a PDF or document. Uploads are UI-only in '
                            'this phase.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton.secondary(
                        label: 'Manage document',
                        icon: Icons.attach_file_rounded,
                        onPressed: _openMediaPage,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save as Draft',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: () => _save(publish: false),
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
                  horizontal: AppSpacing.xs,
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
                      _typeShort(t),
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

  String _typeShort(LessonType t) {
    switch (t) {
      case LessonType.text:
        return 'TEXT';
      case LessonType.video:
        return 'VIDEO';
      case LessonType.document:
        return 'DOCUMENT';
    }
  }
}