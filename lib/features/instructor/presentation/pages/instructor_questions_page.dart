import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_quiz.dart';
import '../../../../mock_data/models/mock_quiz_question.dart';
import '../widgets/question_card.dart';

class InstructorQuestionsPage extends StatefulWidget {
  const InstructorQuestionsPage({super.key, required this.quizId});

  final String quizId;

  @override
  State<InstructorQuestionsPage> createState() =>
      _InstructorQuestionsPageState();
}

class _InstructorQuestionsPageState
    extends State<InstructorQuestionsPage> {
  MockQuiz? _quiz;
  late List<MockQuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _quiz = _findQuiz();
    _questions = List.of(MockQuizQuestions.byQuiz(widget.quizId));
  }

  MockQuiz? _findQuiz() {
    for (final q in MockQuizzes.all) {
      if (q.id == widget.quizId) return q;
    }
    return null;
  }

  Future<void> _delete(MockQuizQuestion q) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete question?',
      message: 'The question will be permanently removed from this quiz.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _questions.removeWhere((x) => x.id == q.id));
    AppSnackbar.showSuccess(context, 'Question deleted (mock).');
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
        title: Text(
          quiz.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: _questions.isEmpty
            ? AppEmptyState(
          icon: Icons.help_outline_rounded,
          title: 'No questions yet',
          message:
          'Add the first question to this quiz. Each question can '
              'have 2–6 options with one correct answer.',
          actionLabel: 'Add Question',
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.instructorCreateQuestion,
            arguments: quiz.id,
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _questions.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final q = _questions[i];
            return QuestionCard(
              question: q,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditQuestion,
                arguments: q.id,
              ),
              onEdit: () => Navigator.of(context).pushNamed(
                AppRoutes.instructorEditQuestion,
                arguments: q.id,
              ),
              onDelete: () => _delete(q),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateQuestion,
          arguments: quiz.id,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Question'),
      ),
    );
  }
}