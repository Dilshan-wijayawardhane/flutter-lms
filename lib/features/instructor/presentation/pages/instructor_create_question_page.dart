import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';

class InstructorCreateQuestionPage extends StatefulWidget {
  const InstructorCreateQuestionPage({
    super.key,
    required this.quizId,
  });

  final String quizId;

  @override
  State<InstructorCreateQuestionPage> createState() =>
      _InstructorCreateQuestionPageState();
}

class _InstructorCreateQuestionPageState
    extends State<InstructorCreateQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '10');
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  int _correctIndex = 0;
  bool _saving = false;

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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Question created (mock).');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Question')),
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
                hint: 'e.g., Which widget lays out children vertically?',
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap the circle next to the correct answer.',
                style: AppTextStyles.caption,
              ),
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
                          label: 'Option ${String.fromCharCode(65 + i)}',
                          validator: (v) => Validators.required(
                            v,
                            field: 'Option ${String.fromCharCode(65 + i)}',
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
                label: 'Create Question',
                icon: Icons.check_rounded,
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