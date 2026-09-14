import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_quiz_question.dart';

class InstructorEditQuestionPage extends StatefulWidget {
  const InstructorEditQuestionPage({
    super.key,
    required this.questionId,
  });

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

  MockQuizQuestion? _question;
  int _correctIndex = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _question = _find();
    final q = _question;
    _questionCtrl.text = q?.text ?? '';
    _pointsCtrl.text = '${q?.points ?? 10}';
    if (q != null) {
      for (final o in q.options) {
        _optionCtrls.add(TextEditingController(text: o));
      }
      _correctIndex = q.correctOptionIndex ?? 0;
    } else {
      _optionCtrls.add(TextEditingController());
      _optionCtrls.add(TextEditingController());
    }
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

  MockQuizQuestion? _find() {
    for (final q in MockQuizQuestions.flutterBasics) {
      if (q.id == widget.questionId) return q;
    }
    return null;
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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Question updated (mock).');
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete question?',
      message: 'The question will be permanently removed from this quiz.',
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
    final q = _question;
    if (q == null) {
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
                validator: (v) {
                  final parsed = int.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
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
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}