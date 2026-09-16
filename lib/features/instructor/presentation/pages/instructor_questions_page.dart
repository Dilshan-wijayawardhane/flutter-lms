import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/data/models/quiz_question.dart';
import '../../providers/instructor_quiz_provider.dart';
import '../widgets/question_card.dart';

class InstructorQuestionsPage extends StatefulWidget {
  const InstructorQuestionsPage({
    super.key,
    required this.courseId,
    required this.quizId,
  });

  final String courseId;
  final String quizId;

  @override
  State<InstructorQuestionsPage> createState() =>
      _InstructorQuestionsPageState();
}

class _InstructorQuestionsPageState
    extends State<InstructorQuestionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorQuizProvider>().loadQuestions(widget.quizId);
    });
  }

  Future<void> _delete(QuizQuestion q) async {
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
        .deleteQuestion(quizId: widget.quizId, questionId: q.id);
    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Question deleted.');
    } else {
      AppSnackbar.showError(context, 'Could not delete.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InstructorQuizProvider>();
    final state = p.questionsStateFor(widget.quizId);
    final questions = p.questionsFor(widget.quizId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Questions')),
      body: SafeArea(
        top: false,
        child: state == LoadState.loading && questions.isEmpty
            ? const AppLoading(message: 'Loading questions…')
            : questions.isEmpty
            ? AppEmptyState(
          icon: Icons.help_outline_rounded,
          title: 'No questions yet',
          message:
          'Add your first question. Each question supports 2–6 options.',
          actionLabel: 'Add Question',
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.instructorCreateQuestion,
            arguments: {
              'courseId': widget.courseId,
              'quizId': widget.quizId,
            },
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: questions.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final q = questions[i];
            return QuestionCard(
              question: q,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditQuestion,
                arguments: {
                  'courseId': widget.courseId,
                  'quizId': widget.quizId,
                  'questionId': q.id,
                },
              ),
              onEdit: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditQuestion,
                arguments: {
                  'courseId': widget.courseId,
                  'quizId': widget.quizId,
                  'questionId': q.id,
                },
              ),
              onDelete: () => _delete(q),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateQuestion,
          arguments: {
            'courseId': widget.courseId,
            'quizId': widget.quizId,
          },
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Question'),
      ),
    );
  }
}