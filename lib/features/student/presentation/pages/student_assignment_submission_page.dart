import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/file_picker_field.dart';
import '../../../../core/widgets/selected_file_card.dart';
import '../../providers/assignment_provider.dart';

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

  // Phase 5 keeps the existing "fake pick" UI. Real file_picker + Dio
  // multipart wiring lands in Phase 7.
  String? _fileName;
  String? _fileSize;
  String? _filePath;
  String? _mimeType;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AssignmentProvider>();
    final existing = provider.submissionFor(widget.assignmentId);
    _textCtrl.text = existing?.textContent ?? '';
    _fileName = existing?.fileName;
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _fakePickFile() {
    setState(() {
      _fileName =
      'submission_${DateTime.now().millisecondsSinceEpoch}.pdf';
      _fileSize = '1.2MB';
      _filePath = null; // Phase 7 wires real path
      _mimeType = 'application/pdf';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final hasText = _textCtrl.text.trim().isNotEmpty;
    final hasFile = _fileName != null;

    if (!hasText && !hasFile) {
      AppSnackbar.showError(
        context,
        'Please provide text or attach a file.',
      );
      return;
    }

    setState(() => _submitting = true);
    final provider = context.read<AssignmentProvider>();

    dynamic submission;

    // Prefer real file upload when a path is available; otherwise text.
    if (hasFile && _filePath != null) {
      submission = await provider.submitFile(
        assignmentId: widget.assignmentId,
        filePath: _filePath!,
        fileName: _fileName!,
        mimeType: _mimeType,
      );
    } else if (hasText) {
      submission = await provider.submitText(
        assignmentId: widget.assignmentId,
        text: _textCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (submission != null) {
      AppSnackbar.showSuccess(context, 'Submission saved.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        provider.detailErrorFor(widget.assignmentId) ??
            'Could not submit. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    final assignment = provider.assignmentById(widget.assignmentId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Submit Assignment')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (assignment != null) ...[
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
                      Text(assignment.title,
                          style: AppTextStyles.labelLarge),
                      const SizedBox(height: 2),
                      Text(assignment.courseName,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (assignment?.allowTextSubmission != false) ...[
                Text('Text submission',
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  controller: _textCtrl,
                  hint:
                  'Type your answer, paste a link, or describe your submission…',
                  maxLines: 6,
                  minLines: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (assignment?.allowFileSubmission != false) ...[
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
                      _filePath = null;
                    }),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppButton.primary(
                label: 'Submit',
                icon: Icons.upload_rounded,
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}