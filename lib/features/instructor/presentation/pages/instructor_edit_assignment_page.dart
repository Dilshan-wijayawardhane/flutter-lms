import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/file_picker_field.dart';
import '../../../../core/widgets/selected_file_card.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/models/mock_assignment.dart';

class InstructorEditAssignmentPage extends StatefulWidget {
  const InstructorEditAssignmentPage({
    super.key,
    required this.assignmentId,
  });

  final String assignmentId;

  @override
  State<InstructorEditAssignmentPage> createState() =>
      _InstructorEditAssignmentPageState();
}

class _InstructorEditAssignmentPageState
    extends State<InstructorEditAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();

  MockAssignment? _assignment;
  DateTime? _dueDate;
  bool _allowText = true;
  bool _allowFile = true;
  String? _attachmentName;
  String? _attachmentSize;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _assignment = _find();
    final a = _assignment;
    _titleCtrl.text = a?.title ?? '';
    _descCtrl.text = a?.description ?? '';
    _pointsCtrl.text = '${a?.maxPoints ?? 100}';
    _dueDate = a?.dueDate;
    _allowText = a?.allowTextSubmission ?? true;
    _allowFile = a?.allowFileSubmission ?? true;
    _attachmentName = a?.attachmentName;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  MockAssignment? _find() {
    for (final a in MockAssignments.all) {
      if (a.id == widget.assignmentId) return a;
    }
    return null;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 365)),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Assignment updated (mock).');
    Navigator.of(context).pop();
  }

  Future<void> _togglePublish() async {
    final a = _assignment;
    if (a == null) return;
    final action =
    a.status == AssignmentStatus.published ? 'Unpublish' : 'Publish';
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: '$action assignment?',
      message: a.status == AssignmentStatus.published
          ? 'Students will no longer be able to submit.'
          : 'Students will be able to submit their work.',
      confirmLabel: action,
      icon: Icons.publish_rounded,
    );
    if (!confirmed || !mounted) return;
    AppSnackbar.showInfo(
      context,
      '$action will call the backend in Phase 2.',
    );
  }

  Future<void> _delete() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete assignment?',
      message:
      'The assignment and all its submissions will be permanently '
          'removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    AppSnackbar.showInfo(
      context,
      'Delete will call the backend in Phase 2.',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final a = _assignment;
    if (a == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Assignment not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Assignment'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
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
              _statusCard(a),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _titleCtrl,
                label: 'Assignment title',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Assignment title'),
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
                      prefixIcon: Icons.emoji_events_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final parsed = int.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Invalid';
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

              Text('Attachment', style: AppTextStyles.headingSmall),
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
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: a.status == AssignmentStatus.published
                    ? 'Unpublish'
                    : 'Publish Assignment',
                icon: a.status == AssignmentStatus.published
                    ? Icons.pause_circle_outline_rounded
                    : Icons.publish_rounded,
                onPressed: _togglePublish,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'View Submissions',
                icon: Icons.people_alt_outlined,
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.instructorSubmissions,
                  arguments: a.id,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard(MockAssignment a) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Course', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(a.courseName, style: AppTextStyles.labelLarge),
              ],
            ),
          ),
          if (a.status == AssignmentStatus.published)
            const AppStatusChip(status: AppStatus.published)
          else
            const AppStatusChip(status: AppStatus.draft),
        ],
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