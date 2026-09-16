import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/instructor_assignment_provider.dart';

class InstructorGradeSubmissionPage extends StatefulWidget {
  const InstructorGradeSubmissionPage({
    super.key,
    required this.submissionId,
  });

  final String submissionId;

  @override
  State<InstructorGradeSubmissionPage> createState() =>
      _InstructorGradeSubmissionPageState();
}

class _InstructorGradeSubmissionPageState
    extends State<InstructorGradeSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _scoreCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = context
        .read<InstructorAssignmentProvider>()
        .submission(widget.submissionId);
    if (s?.score != null) {
      _scoreCtrl.text = '${s!.score}';
    }
    _feedbackCtrl.text = s?.feedback ?? '';
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _grade() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<InstructorAssignmentProvider>();
    final ok = await p.gradeSubmission(
      submissionId: widget.submissionId,
      score: int.parse(_scoreCtrl.text.trim()),
      feedback: _feedbackCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      AppSnackbar.showSuccess(context, 'Submission graded.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(context, 'Could not grade.');
    }
  }

  Future<void> _requestResubmission() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<InstructorAssignmentProvider>();
    final ok = await p.requestResubmission(
      submissionId: widget.submissionId,
      feedback: _feedbackCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      AppSnackbar.showSuccess(context, 'Resubmission requested.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(context, 'Could not request resubmission.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context
        .watch<InstructorAssignmentProvider>()
        .submission(widget.submissionId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Grade Submission')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (s != null) ...[
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
                      Text(s.assignmentTitle,
                          style: AppTextStyles.headingSmall),
                      const SizedBox(height: 4),
                      Text(s.studentName ?? s.studentId,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                controller: _scoreCtrl,
                label: 'Score',
                hint: 'Out of ${s?.maxPoints ?? 100}',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Enter a valid score';
                  final max = s?.maxPoints ?? 100;
                  if (n > max) return 'Cannot exceed $max';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _feedbackCtrl,
                label: 'Feedback',
                maxLines: 6,
                minLines: 4,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Provide at least 10 characters of feedback'
                    : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Submit Grade',
                icon: Icons.check_circle_rounded,
                isLoading: _saving,
                onPressed: _saving ? null : _grade,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Request Resubmission',
                icon: Icons.refresh_rounded,
                onPressed: _saving ? null : _requestResubmission,
              ),
            ],
          ),
        ),
      ),
    );
  }
}