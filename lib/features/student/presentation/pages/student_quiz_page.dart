import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../data/models/quiz_question.dart';
import '../../data/models/quiz_submission.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/quiz_question_card.dart';

class StudentQuizPage extends StatefulWidget {
  const StudentQuizPage({super.key, required this.quizId});

  final String quizId;

  @override
  State<StudentQuizPage> createState() => _StudentQuizPageState();
}

class _StudentQuizPageState extends State<StudentQuizPage> {
  int _index = 0;
  final Map<int, int> _answers = {};
  String? _attemptId;
  bool _starting = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  Future<void> _start() async {
    setState(() => _starting = true);
    final p = context.read<QuizProvider>();
    await p.loadDetails(widget.quizId);
    final start = await p.startAttempt(widget.quizId);
    if (!mounted) return;
    setState(() {
      _starting = false;
      _attemptId = start?.attemptId;
    });
    if (start == null) {
      AppSnackbar.showError(context, 'Could not start quiz.');
    }
  }

  Future<void> _submit() async {
    final attemptId = _attemptId;
    if (attemptId == null) {
      AppSnackbar.showError(context, 'Attempt not started.');
      return;
    }

    final questions =
    context.read<QuizProvider>().questionsFor(widget.quizId);
    final unanswered = questions.length - _answers.length;

    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Submit quiz?',
      message: unanswered > 0
          ? 'You still have $unanswered unanswered question(s). Submit anyway?'
          : 'Your answers will be submitted for grading.',
      confirmLabel: 'Submit',
      icon: Icons.quiz_outlined,
    );
    if (!confirmed || !mounted) return;

    setState(() => _submitting = true);

    final answerMap = <String, int>{};
    for (final entry in _answers.entries) {
      answerMap[questions[entry.key].id] = entry.value;
    }

    final attempt = await context
        .read<QuizProvider>()
        .submitAttempt(QuizSubmission(
      attemptId: attemptId,
      answers: answerMap,
    ));

    if (!mounted) return;
    setState(() => _submitting = false);

    if (attempt != null) {
      AppSnackbar.showSuccess(context, 'Quiz submitted.');
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.studentQuizResult,
        arguments: widget.quizId,
      );
    } else {
      AppSnackbar.showError(context, 'Could not submit.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final state = provider.detailStateFor(widget.quizId);
    final quiz = provider.quizById(widget.quizId);
    final questions = provider.questionsFor(widget.quizId);

    if (_starting ||
        (state == LoadState.loading && questions.isEmpty)) {
      return const Scaffold(
        body: SafeArea(
          child: AppLoading(message: 'Preparing quiz…'),
        ),
      );
    }
    if (state == LoadState.error && questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          title: 'Could not load quiz',
          message: provider.detailErrorFor(widget.quizId) ??
              'Please try again.',
          onRetry: _start,
        ),
      );
    }
    if (quiz == null || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const AppEmptyState(
          icon: Icons.quiz_outlined,
          title: 'Quiz unavailable',
          message: 'This quiz does not have any questions yet.',
        ),
      );
    }

    final question = questions[_index];
    final isLast = _index == questions.length - 1;
    final isFirst = _index == 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await AppConfirmationDialog.show(
          context,
          title: 'Leave quiz?',
          message: 'Your progress will be lost.',
          confirmLabel: 'Leave',
          isDestructive: true,
          icon: Icons.warning_amber_rounded,
        );
        if (leave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
          child: Column(
            children: [
              _progressStrip(questions.length),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: QuizQuestionCard(
                    question: question,
                    selectedIndex: _answers[_index],
                    onSelected: (i) =>
                        setState(() => _answers[_index] = i),
                    currentIndex: _index,
                    totalQuestions: questions.length,
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

  Widget _progressStrip(int total) {
    final value = (_index + 1) / total;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            BorderRadius.circular(AppSpacing.radiusPill),
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
            '${_answers.length} of $total answered',
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
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
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