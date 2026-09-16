import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../../../student/data/models/quiz.dart';
import '../../providers/instructor_quiz_provider.dart';

class InstructorEditQuizPage extends StatefulWidget {
  const InstructorEditQuizPage({
    super.key,
    required this.courseId,
    required this.quizId,
  });

  final String courseId;
  final String quizId;

  @override
  State<InstructorEditQuizPage> createState() =>
      _InstructorEditQuizPageState();
}

class _InstructorEditQuizPageState
    extends State<InstructorEditQuizPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _passingCtrl;
  late final TextEditingController _attemptsCtrl;

  Quiz? _quiz;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _quiz = context
        .read<InstructorQuizProvider>()
        .quizById(widget.courseId, widget.quizId);
    _titleCtrl = TextEditingController(text: _quiz?.title ?? '');
    _descCtrl = TextEditingController(text: _quiz?.description ?? '');
    _durationCtrl =
        TextEditingController(text: '${_quiz?.durationMinutes ?? 20}');
    _passingCtrl =
        TextEditingController(text: '${_quiz?.passingScore ?? 60}');
    _attemptsCtrl =
        TextEditingController(text: '${_quiz?.maxAttempts ?? 3}');
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<InstructorQuizProvider>();
    final ok = await p.updateQuiz(
      courseId: widget.courseId,
      quizId: widget.quizId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      durationMinutes: int.tryParse(_durationCtrl.text.trim()),
      passingScore: int.tryParse(_passingCtrl.text.trim()),
      maxAttempts: int.tryParse(_attemptsCtrl.text.trim()),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      AppSnackbar.showSuccess(context, 'Quiz updated.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(context, 'Could not update.');
    }
  }

  Future<void> _publish() async {
    final ok = await context.read<InstructorQuizProvider>().publishQuiz(
      courseId: widget.courseId,
      quizId: widget.quizId,
    );
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Quiz published.' : 'Could not publish.',
    );
  }

  Future<void> _delete() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete quiz?',
      message: 'The quiz and all attempts will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    final ok = await context.read<InstructorQuizProvider>().deleteQuiz(
      courseId: widget.courseId,
      quizId: widget.quizId,
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Quiz deleted.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _quiz;
    if (q == null) {
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
              _statusCard(q),
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
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      controller: _passingCtrl,
                      label: 'Passing (%)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _attemptsCtrl,
                label: 'Max attempts',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: q.status == QuizStatus.published
                    ? 'Unpublish (mock)'
                    : 'Publish Quiz',
                icon: q.status == QuizStatus.published
                    ? Icons.pause_circle_outline_rounded
                    : Icons.publish_rounded,
                onPressed: q.status == QuizStatus.published
                    ? null
                    : _publish,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Manage Questions',
                icon: Icons.list_alt_rounded,
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.instructorQuestions,
                  arguments: {
                    'courseId': widget.courseId,
                    'quizId': widget.quizId,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard(Quiz q) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text('${q.questionCount} questions · ${q.totalPoints} pts',
              style: AppTextStyles.caption),
          const Spacer(),
          if (q.status == QuizStatus.published)
            const AppStatusChip(status: AppStatus.published)
          else
            const AppStatusChip(status: AppStatus.draft),
        ],
      ),
    );
  }
}