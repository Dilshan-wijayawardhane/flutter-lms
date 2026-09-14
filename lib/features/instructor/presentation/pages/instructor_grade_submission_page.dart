import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/models/mock_submission.dart';

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

  MockSubmission? _submission;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _submission = _find();
    if (_submission?.score != null) {
      _scoreCtrl.text = '${_submission!.score}';
    }
    _feedbackCtrl.text = _submission?.feedback ?? '';
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  MockSubmission? _find() {
    for (final s in MockSubmissions.all) {
      if (s.id == widget.submissionId) return s;
    }
    return null;
  }

  Future<void> _grade() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Submission graded (mock).');
    Navigator.of(context).pop();
  }

  Future<void> _requestResubmission() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(
      context,
      'Resubmission requested (mock).',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = _submission;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Submission not found')),
      );
    }

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
              _headerCard(s),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: _scoreCtrl,
                label: 'Score',
                hint: 'Out of ${s.maxPoints ?? 100}',
                prefixIcon: Icons.emoji_events_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a score';
                  }
                  final parsed = int.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid number';
                  }
                  final max = s.maxPoints ?? 100;
                  if (parsed > max) {
                    return 'Score cannot exceed $max';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _feedbackCtrl,
                label: 'Feedback',
                hint:
                'Provide constructive feedback for the student. This is '
                    'shown to the student.',
                maxLines: 6,
                minLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Feedback is required';
                  }
                  if (v.trim().length < 10) {
                    return 'Feedback should be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              AppButton.primary(
                label: s.status == SubmissionStatus.resubmissionRequired
                    ? 'Re-grade Submission'
                    : 'Submit Grade',
                icon: Icons.check_circle_rounded,
                isLoading: _saving,
                onPressed: _grade,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Request Resubmission',
                icon: Icons.refresh_rounded,
                onPressed: _saving ? null : _requestResubmission,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Requesting resubmission will notify the student and allow '
                    'them to submit again.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard(MockSubmission s) {
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
          Text(s.assignmentTitle,
              style: AppTextStyles.headingSmall),
          const SizedBox(height: 4),
          Text(s.studentName, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}