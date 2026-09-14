import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_quiz.dart';
import '../../../../mock_data/models/mock_quiz_question.dart';
import '../widgets/quiz_question_card.dart';

class StudentQuizPage extends StatefulWidget {
  const StudentQuizPage({super.key, required this.quizId});

  final String quizId;

  @override
  State<StudentQuizPage> createState() => _StudentQuizPageState();
}

class _StudentQuizPageState extends State<StudentQuizPage> {
  int _index = 0;
  final Map<int, int> _answers = {}; // questionIndex -> optionIndex

  MockQuiz? _quiz;
  List<MockQuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    for (final q in MockQuizzes.all) {
      if (q.id == widget.quizId) {
        _quiz = q;
        break;
      }
    }
    _questions = MockQuizQuestions.byQuiz(widget.quizId);
  }

  Future<void> _submit() async {
    final unanswered = _questions.length - _answers.length;
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Submit quiz?',
      message: unanswered > 0
          ? 'You still have $unanswered unanswered question(s). '
          'Do you want to submit anyway?'
          : 'Your answers will be submitted for grading.',
      confirmLabel: 'Submit',
      icon: Icons.quiz_outlined,
    );
    if (!confirmed || !mounted) return;

    // Phase 1: no scoring logic in Flutter. We simply navigate to a
    // mock result page. In Phase 2 the score/pass-fail will come from
    // the backend.
    AppSnackbar.showSuccess(context, 'Quiz submitted (mock)');
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.studentQuizResult,
      arguments: widget.quizId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quiz == null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const AppEmptyState(
          icon: Icons.quiz_outlined,
          title: 'Quiz unavailable',
          message: 'This quiz does not have any questions yet.',
        ),
      );
    }

    final question = _questions[_index];
    final isLast = _index == _questions.length - 1;
    final isFirst = _index == 0;

    return WillPopScope(
      onWillPop: () async {
        final leave = await AppConfirmationDialog.show(
          context,
          title: 'Leave quiz?',
          message:
          'Your progress will be lost. Are you sure you want to leave?',
          confirmLabel: 'Leave',
          isDestructive: true,
          icon: Icons.warning_amber_rounded,
        );
        return leave;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            _quiz!.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _progressStrip(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: QuizQuestionCard(
                    question: question,
                    selectedIndex: _answers[_index],
                    onSelected: (i) =>
                        setState(() => _answers[_index] = i),
                    currentIndex: _index,
                    totalQuestions: _questions.length,
                  ),
                ),
              ),
              _navBar(isFirst, isLast),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressStrip() {
    final value = (_index + 1) / _questions.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
              const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_answers.length} of ${_questions.length} answered',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _navBar(bool isFirst, bool isLast) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Previous',
                icon: Icons.arrow_back_rounded,
                isDisabled: isFirst,
                onPressed: () => setState(() => _index--),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: isLast
                  ? AppButton.primary(
                label: 'Submit',
                icon: Icons.check_rounded,
                onPressed: _submit,
              )
                  : AppButton.primary(
                label: 'Next',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => setState(() => _index++),
              ),
            ),
          ],
        ),
      ),
    );
  }
}