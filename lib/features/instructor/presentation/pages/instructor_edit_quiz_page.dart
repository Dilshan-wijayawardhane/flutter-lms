import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_quiz.dart';

class InstructorEditQuizPage extends StatefulWidget {
  const InstructorEditQuizPage({super.key, required this.quizId});

  final String quizId;

  @override
  State<InstructorEditQuizPage> createState() =>
      _InstructorEditQuizPageState();
}

class _InstructorEditQuizPageState
    extends State<InstructorEditQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _passingCtrl = TextEditingController();
  final _attemptsCtrl = TextEditingController();

  MockQuiz? _quiz;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _quiz = _find();
    final q = _quiz;
    _titleCtrl.text = q?.title ?? '';
    _descCtrl.text = q?.description ?? '';
    _durationCtrl.text = '${q?.durationMinutes ?? 20}';
    _passingCtrl.text = '${q?.passingScore ?? 60}';
    _attemptsCtrl.text = '${q?.maxAttempts ?? 3}';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _passingCtrl.dispose();
    _attemptsCtrl.dispose();
    super.dispose();
  }

  MockQuiz? _find() {
    for (final q in MockQuizzes.all) {
      if (q.id == widget.quizId) return q;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Quiz updated (mock).');
    Navigator.of(context).pop();
  }

  Future<void> _togglePublish() async {
    final q = _quiz;
    if (q == null) return;
    final action = q.status == QuizStatus.published ? 'Unpublish' : 'Publish';
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: '$action quiz?',
      message: q.status == QuizStatus.published
          ? 'The quiz will no longer be visible to students.'
          : 'The quiz will become available to students.',
      confirmLabel: action,
      icon: Icons.publish_rounded,
    );
    if (!confirmed || !mounted) return;
    AppSnackbar.showInfo(
      context,
      '$action will call the backend in Phase 2.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;
    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Questions',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.instructorQuestions,
              arguments: quiz.id,
            ),
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
              _statusCard(quiz),
              const SizedBox(height: AppSpacing.md),

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
                label: 'Description',
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
                      validator: (v) => _positiveInt(v, 'Duration'),
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
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: quiz.status == QuizStatus.published
                    ? 'Unpublish'
                    : 'Publish Quiz',
                icon: quiz.status == QuizStatus.published
                    ? Icons.pause_circle_outline_rounded
                    : Icons.publish_rounded,
                onPressed: _togglePublish,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Manage Questions',
                icon: Icons.list_alt_rounded,
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.instructorQuestions,
                  arguments: quiz.id,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard(MockQuiz quiz) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Questions', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text('${quiz.questionCount}',
                    style: AppTextStyles.labelLarge),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total points', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text('${quiz.totalPoints}',
                    style: AppTextStyles.labelLarge),
              ],
            ),
          ),
          if (quiz.status == QuizStatus.published)
            const AppStatusChip(status: AppStatus.published)
          else
            const AppStatusChip(status: AppStatus.draft),
        ],
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