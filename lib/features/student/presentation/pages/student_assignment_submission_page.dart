import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/file_picker_field.dart';
import '../../../../core/widgets/selected_file_card.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/models/mock_assignment.dart';
import '../../../../mock_data/models/mock_submission.dart';

class StudentAssignmentSubmissionPage extends StatefulWidget {
  const StudentAssignmentSubmissionPage({
    super.key,
    required this.assignmentId,
  });

  final String assignmentId;

  @override
  State<StudentAssignmentSubmissionPage> createState() =>
      _StudentAssignmentSubmissionPageState();
}

class _StudentAssignmentSubmissionPageState
    extends State<StudentAssignmentSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();

  // Mock "selected" file — in Phase 2, this becomes a real picked file.
  String? _fileName;
  String? _fileSize;
  bool _isSubmitting = false;

  MockAssignment? _assignment;

  @override
  void initState() {
    super.initState();
    _assignment = _find(widget.assignmentId);
    final existing = MockSubmissions.byStudentAndAssignment(
      'user_student_001',
      widget.assignmentId,
    );
    if (existing != null) {
      _textCtrl.text = existing.textContent ?? '';
      _fileName = existing.fileName;
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  MockAssignment? _find(String id) {
    for (final a in MockAssignments.all) {
      if (a.id == id) return a;
    }
    return null;
  }

  void _fakePickFile() {
    // Phase 1: no real file picker. We set a mock selection so the UI can
    // demonstrate the selected-file state.
    setState(() {
      _fileName = 'my_submission_${DateTime.now().millisecondsSinceEpoch}.pdf';
      _fileSize = '1.2MB';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_textCtrl.text.trim().isEmpty && _fileName == null) {
      AppSnackbar.showError(
        context,
        'Please provide text or attach a file.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    AppSnackbar.showSuccess(context, 'Submission saved (mock).');
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

    final existing = MockSubmissions.byStudentAndAssignment(
      'user_student_001',
      a.id,
    );
    final isResubmission =
        existing?.status == SubmissionStatus.resubmissionRequired;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isResubmission ? 'Resubmit' : 'Submit Assignment'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _assignmentSummary(a),
              const SizedBox(height: AppSpacing.lg),

              if (a.allowTextSubmission) ...[
                Text('Text submission',
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  controller: _textCtrl,
                  hint:
                  'Type your answer, paste a link, or describe your submission...',
                  maxLines: 6,
                  minLines: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              if (a.allowFileSubmission) ...[
                Text('File submission',
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.xs),
                if (_fileName == null)
                  FilePickerField(
                    title: 'Attach a file',
                    onPickRequested: _fakePickFile,
                  )
                else
                  SelectedFileCard(
                    fileName: _fileName!,
                    fileSizeLabel: _fileSize,
                    onRemove: () => setState(() {
                      _fileName = null;
                      _fileSize = null;
                    }),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],

              AppButton.primary(
                label: isResubmission ? 'Resubmit' : 'Submit',
                icon: Icons.upload_rounded,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _assignmentSummary(MockAssignment a) {
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
          Text(a.title, style: AppTextStyles.labelLarge),
          const SizedBox(height: 2),
          Text(a.courseName, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}