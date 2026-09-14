import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_quiz.dart';

class StudentQuizResultPage extends StatelessWidget {
  const StudentQuizResultPage({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context) {
    final quiz = _findQuiz(quizId);
    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    // Phase 1: static mock result. Phase 2: this will come from backend.
    final totalPoints = quiz.totalPoints;
    final score = (totalPoints * 0.8).round();
    final percent = (score / totalPoints) * 100;
    final passed = percent >= quiz.passingScore;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _resultHero(context, quiz, score, totalPoints, percent, passed),
            const SizedBox(height: AppSpacing.lg),
            _summaryRow(quiz, percent, passed),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius:
                BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'This result is a mock preview. In the backend '
                          'integration phase, the score and pass/fail value '
                          'will come directly from the server.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: 'View Attempt History',
              icon: Icons.history_rounded,
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.studentQuizAttempts,
                arguments: quiz.id,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton.secondary(
              label: 'Back to Course',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  MockQuiz? _findQuiz(String id) {
    for (final q in MockQuizzes.all) {
      if (q.id == id) return q;
    }
    return null;
  }

  Widget _resultHero(
      BuildContext context,
      MockQuiz quiz,
      int score,
      int totalPoints,
      double percent,
      bool passed,
      ) {
    final color = passed ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(
              passed
                  ? Icons.emoji_events_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              size: 44,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            passed ? 'Congratulations!' : 'Not quite there',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            passed
                ? 'You passed "${quiz.title}".'
                : 'You did not pass "${quiz.title}" this time.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statColumn('Score', '$score/$totalPoints'),
              _statColumn('Percent', '${percent.toStringAsFixed(0)}%'),
              _statColumn('Passing', '${quiz.passingScore}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headingSmall),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _summaryRow(MockQuiz quiz, double percent, bool passed) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryItem('Quiz', quiz.title),
          const Divider(height: AppSpacing.lg),
          _summaryItem(
            'Result',
            passed ? 'Passed' : 'Failed',
            valueColor:
            passed ? AppColors.success : AppColors.danger,
          ),
          const Divider(height: AppSpacing.lg),
          _summaryItem(
            'Duration',
            '${quiz.durationMinutes} minutes',
          ),
          const Divider(height: AppSpacing.lg),
          _summaryItem(
            'Max attempts',
            '${quiz.maxAttempts}',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
      String label,
      String value, {
        Color? valueColor,
      }) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.labelLarge
              .copyWith(color: valueColor),
        ),
      ],
    );
  }
}