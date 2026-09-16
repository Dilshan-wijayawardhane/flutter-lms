import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../../../student/data/models/assignment.dart';
import '../../providers/instructor_assignment_provider.dart';

class InstructorEditAssignmentPage extends StatefulWidget {
  const InstructorEditAssignmentPage({
    super.key,
    required this.courseId,
    required this.assignmentId,
  });

  final String courseId;
  final String assignmentId;

  @override
  State<InstructorEditAssignmentPage> createState() =>
      _InstructorEditAssignmentPageState();
}

class _InstructorEditAssignmentPageState
    extends State<InstructorEditAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _pointsCtrl;

  Assignment? _assignment;
  DateTime? _dueDate;
  bool _allowText = true;
  bool _allowFile = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final list = context
        .read<InstructorAssignmentProvider>()
        .assignmentsFor(widget.courseId);
    for (final a in list) {
      if (a.id == widget.assignmentId) {
        _assignment = a;
        break;
      }
    }
    _titleCtrl = TextEditingController(text: _assignment?.title ?? '');
    _descCtrl =
        TextEditingController(text: _assignment?.description ?? '');
    _pointsCtrl =
        TextEditingController(text: '${_assignment?.maxPoints ?? 100}');
    _dueDate = _assignment?.dueDate;
    _allowText = _assignment?.allowTextSubmission ?? true;
    _allowFile = _assignment?.allowFileSubmission ?? true;
  }

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
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<InstructorAssignmentProvider>();
    final ok = await p.updateAssignment(
      courseId: widget.courseId,
      assignmentId: widget.assignmentId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: _dueDate,
      maxPoints: int.tryParse(_pointsCtrl.text.trim()),
      allowTextSubmission: _allowText,
      allowFileSubmission: _allowFile,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      AppSnackbar.showSuccess(context, 'Assignment updated.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(context, 'Could not update.');
    }
  }

  Future<void> _publish() async {
    final ok = await context
        .read<InstructorAssignmentProvider>()
        .publishAssignment(
      courseId: widget.courseId,
      assignmentId: widget.assignmentId,
    );
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Assignment published.' : 'Could not publish.',
    );
  }

  Future<void> _delete() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete assignment?',
      message: 'All submissions will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    final ok = await context
        .read<InstructorAssignmentProvider>()
        .deleteAssignment(
      courseId: widget.courseId,
      assignmentId: widget.assignmentId,
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Assignment deleted.');
      Navigator.of(context).pop();
    }
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
              _statusCard(a),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _titleCtrl,
                label: 'Assignment title',
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
                                style: AppTextStyles.bodyMedium,
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
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (a.status == AssignmentStatus.draft)
                AppButton.secondary(
                  label: 'Publish Assignment',
                  icon: Icons.publish_rounded,
                  onPressed: _publish,
                ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'View Submissions',
                icon: Icons.people_alt_outlined,
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.instructorSubmissions,
                  arguments: {
                    'courseId': widget.courseId,
                    'assignmentId': widget.assignmentId,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard(Assignment a) {
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
            child: Text(a.courseName,
                style: AppTextStyles.labelLarge),
          ),
          if (a.status == AssignmentStatus.published)
            const AppStatusChip(status: AppStatus.published)
          else
            const AppStatusChip(status: AppStatus.draft),
        ],
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