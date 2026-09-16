import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/instructor_assignment_provider.dart';

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
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_allowText && !_allowFile) {
      AppSnackbar.showError(
        context,
        'Enable at least one submission type.',
      );
      return;
    }

    setState(() => _saving = true);
    final p = context.read<InstructorAssignmentProvider>();
    final created = await p.createAssignment(
      courseId: widget.courseId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: _dueDate,
      maxPoints: int.tryParse(_pointsCtrl.text.trim()) ?? 100,
      allowTextSubmission: _allowText,
      allowFileSubmission: _allowFile,
      publish: publish,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (created != null) {
      AppSnackbar.showSuccess(
        context,
        publish ? 'Assignment published.' : 'Saved as draft.',
      );
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        p.listErrorFor(widget.courseId) ??
            'Could not create assignment.',
      );
    }
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
                prefixIcon: Icons.title_rounded,
                validator: (v) => Validators.minLength(v, 3,
                    field: 'Assignment title'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'Description',
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
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Invalid';
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
                            const Icon(Icons.event_outlined,
                                size: 18,
                                color: AppColors.textSecondary),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _dueDate == null
                                    ? 'Due date'
                                    : Formatters.date(_dueDate),
                                style: AppTextStyles.bodyMedium
                                    .copyWith(
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
              _switchRow('Allow text submission', _allowText,
                      (v) => setState(() => _allowText = v)),
              _switchRow('Allow file submission', _allowFile,
                      (v) => setState(() => _allowFile = v)),
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

  Widget _switchRow(
      String title,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
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
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}