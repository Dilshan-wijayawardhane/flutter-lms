import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/instructor_quiz_provider.dart';

class InstructorCreateQuizPage extends StatefulWidget {
  const InstructorCreateQuizPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorCreateQuizPage> createState() =>
      _InstructorCreateQuizPageState();
}

class _InstructorCreateQuizPageState
    extends State<InstructorCreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '20');
  final _passingCtrl = TextEditingController(text: '60');
  final _attemptsCtrl = TextEditingController(text: '3');

  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _passingCtrl.dispose();
    _attemptsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final p = context.read<InstructorQuizProvider>();
    final created = await p.createQuiz(
      courseId: widget.courseId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      durationMinutes: int.tryParse(_durationCtrl.text.trim()) ?? 20,
      passingScore: int.tryParse(_passingCtrl.text.trim()) ?? 60,
      maxAttempts: int.tryParse(_attemptsCtrl.text.trim()) ?? 3,
      publish: publish,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (created != null) {
      AppSnackbar.showSuccess(
        context,
        publish ? 'Quiz published.' : 'Quiz saved as draft.',
      );
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        p.listErrorFor(widget.courseId) ?? 'Could not create quiz.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Quiz')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Quiz title',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Quiz title'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'Description (optional)',
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _durationCtrl,
                      label: 'Duration (min)',
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
                    child: AppTextField(
                      controller: _passingCtrl,
                      label: 'Passing (%)',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1 || n > 100) {
                          return '1–100';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _attemptsCtrl,
                label: 'Max attempts',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Invalid';
                  return null;
                },
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
}