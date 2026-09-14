import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/file_picker_field.dart';
import '../../../../core/widgets/selected_file_card.dart';

class InstructorCreateAssignmentPage extends StatefulWidget {
  const InstructorCreateAssignmentPage({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<InstructorCreateAssignmentPage> createState() =>
      _InstructorCreateAssignmentPageState();
}

class _InstructorCreateAssignmentPageState
    extends State<InstructorCreateAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '100');

  DateTime? _dueDate;
  bool _allowText = true;
  bool _allowFile = true;
  String? _attachmentName;
  String? _attachmentSize;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _fakePickAttachment() {
    setState(() {
      _attachmentName =
      'assignment_brief_${DateTime.now().millisecondsSinceEpoch}.pdf';
      _attachmentSize = '340KB';
    });
  }

  Future<void> _save({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_allowText && !_allowFile) {
      AppSnackbar.showError(
        context,
        'Enable at least one submission type (text or file).',
      );
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(
      context,
      publish
          ? 'Assignment published (mock).'
          : 'Assignment saved as draft (mock).',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Assignment')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Assignment title',
                hint: 'e.g., Build Your First Flutter App',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Assignment title'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _descCtrl,
                label: 'Description',
                hint:
                'Explain what students should do and any requirements.',
                maxLines: 6,
                minLines: 4,
                validator: (v) =>
                    Validators.minLength(v, 20, field: 'Description'),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _pointsCtrl,
                      label: 'Max points',
                      prefixIcon: Icons.emoji_events_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final parsed = int.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDueDate,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm,
                      ),
                      child: Container(
                        height: AppSpacing.inputHeight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _dueDate == null
                                    ? 'Due date'
                                    : Formatters.date(_dueDate),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _dueDate == null
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Submission options',
                  style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              _switchRow(
                title: 'Allow text submission',
                value: _allowText,
                onChanged: (v) => setState(() => _allowText = v),
              ),
              _switchRow(
                title: 'Allow file submission',
                value: _allowFile,
                onChanged: (v) => setState(() => _allowFile = v),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Attachment (optional)',
                  style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Attach a brief or resource file for students.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_attachmentName == null)
                FilePickerField(
                  title: 'Attach file',
                  onPickRequested: _fakePickAttachment,
                )
              else
                SelectedFileCard(
                  fileName: _attachmentName!,
                  fileSizeLabel: _attachmentSize,
                  onRemove: () => setState(() {
                    _attachmentName = null;
                    _attachmentSize = null;
                  }),
                ),

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

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.bodyMedium),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}