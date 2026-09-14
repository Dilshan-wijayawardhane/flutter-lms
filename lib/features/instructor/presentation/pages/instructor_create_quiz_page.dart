import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';

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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(
      context,
      publish ? 'Quiz published (mock).' : 'Quiz saved as draft (mock).',
    );
    Navigator.of(context).pop();
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
                hint: 'e.g., Flutter Basics Quiz',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Quiz title'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'Description (optional)',
                hint: 'What will this quiz cover?',
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
                      prefixIcon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          _positiveInt(v, 'Duration'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      controller: _passingCtrl,
                      label: 'Passing (%)',
                      prefixIcon: Icons.flag_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final parsed = int.tryParse(v ?? '');
                        if (parsed == null || parsed < 1 || parsed > 100) {
                          return 'Must be 1–100';
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
                prefixIcon: Icons.repeat_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => _positiveInt(v, 'Attempts'),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save as Draft',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: () => _save(publish: false),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Save & Publish',
                icon: Icons.publish_rounded,
                onPressed: _saving ? null : () => _save(publish: true),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Add questions after saving. Publishing requires at least '
                    'one question.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _positiveInt(String? v, String field) {
    final parsed = int.tryParse(v ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid $field';
    }
    return null;
  }
}