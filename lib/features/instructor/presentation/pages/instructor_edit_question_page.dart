import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../student/data/models/quiz_question.dart';
import '../../providers/instructor_quiz_provider.dart';

class InstructorEditQuestionPage extends StatefulWidget {
  const InstructorEditQuestionPage({
    super.key,
    required this.courseId,
    required this.quizId,
    required this.questionId,
  });

  final String courseId;
  final String quizId;
  final String questionId;

  @override
  State<InstructorEditQuestionPage> createState() =>
      _InstructorEditQuestionPageState();
}

class _InstructorEditQuestionPageState
    extends State<InstructorEditQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [];

  QuizQuestion? _question;
  int _correctIndex = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final list = context
        .read<InstructorQuizProvider>()
        .questionsFor(widget.quizId);
    for (final q in list) {
      if (q.id == widget.questionId) {
        _question = q;
        break;
      }
    }

    _questionCtrl.text = _question?.text ?? '';
    _pointsCtrl.text = '${_question?.points ?? 10}';
    for (final o in _question?.options ?? const <String>[]) {
      _optionCtrls.add(TextEditingController(text: o));
    }
    if (_optionCtrls.isEmpty) {
      _optionCtrls.add(TextEditingController());
      _optionCtrls.add(TextEditingController());
    }
    // Correct option isn't returned by the student-facing model.
    // Default to first.
    _correctIndex = 0;
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _pointsCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionCtrls.length >= 6) return;
    setState(() => _optionCtrls.add(TextEditingController()));
  }

  void _removeOption(int i) {
    if (_optionCtrls.length <= 2) return;
    setState(() {
      _optionCtrls.removeAt(i).dispose();
      if (_correctIndex >= _optionCtrls.length) {
        _correctIndex = _optionCtrls.length - 1;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final options = _optionCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final p = context.read<InstructorQuizProvider>();
    final ok = await p.updateQuestion(
      quizId: widget.quizId,
      questionId: widget.questionId,
      text: _questionCtrl.text.trim(),
      options: options,
      correctOptionIndex: _correctIndex,
      points: int.tryParse(_pointsCtrl.text.trim()),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      AppSnackbar.showSuccess(context, 'Question updated.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(context, 'Could not update question.');
    }
  }

  Future<void> _delete() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete question?',
      message: 'The question will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    final ok = await context
        .read<InstructorQuizProvider>()
        .deleteQuestion(
      quizId: widget.quizId,
      questionId: widget.questionId,
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Question deleted.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_question == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Question not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Question'),
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
              AppTextField(
                controller: _questionCtrl,
                label: 'Question',
                maxLines: 4,
                minLines: 2,
                validator: (v) =>
                    Validators.minLength(v, 5, field: 'Question'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _pointsCtrl,
                label: 'Points',
                prefixIcon: Icons.emoji_events_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Options', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              ...List.generate(_optionCtrls.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _correctIndex = i),
                          child: Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _correctIndex == i
                                  ? AppColors.success
                                  : AppColors.surfaceVariant,
                              border: Border.all(
                                color: _correctIndex == i
                                    ? AppColors.success
                                    : AppColors.border,
                              ),
                            ),
                            child: _correctIndex == i
                                ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppTextField(
                          controller: _optionCtrls[i],
                          label:
                          'Option ${String.fromCharCode(65 + i)}',
                          validator: (v) => Validators.required(
                            v,
                            field:
                            'Option ${String.fromCharCode(65 + i)}',
                          ),
                        ),
                      ),
                      if (_optionCtrls.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: IconButton(
                            onPressed: () => _removeOption(i),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              if (_optionCtrls.length < 6)
                OutlinedButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add option'),
                ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}