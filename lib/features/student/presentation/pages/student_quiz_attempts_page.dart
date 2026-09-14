import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_quiz_attempt.dart';

class StudentQuizAttemptsPage extends StatelessWidget {
  const StudentQuizAttemptsPage({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context) {
    final attempts = MockQuizAttempts.student1Attempts
        .where((a) => a.quizId == quizId)
        .toList()
      ..sort((a, b) =>
          (b.submittedAt ?? DateTime(0)).compareTo(a.submittedAt ?? DateTime(0)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Attempt History')),
      body: SafeArea(
        top: false,
        child: attempts.isEmpty
            ? const AppEmptyState(
          icon: Icons.history_rounded,
          title: 'No attempts yet',
          message: 'Your quiz attempts will appear here.',
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: attempts.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _attemptCard(attempts[i]),
        ),
      ),
    );
  }

  Widget _attemptCard(MockQuizAttempt attempt) {
    final passed = attempt.passed ?? false;
    final color = passed ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  passed ? 'PASSED' : 'FAILED',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Attempt ${attempt.attemptNumber}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(attempt.quizTitle,
              style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _info(Icons.star_rounded,
                  '${attempt.score ?? '—'}/${attempt.totalPoints ?? '—'}'),
              const SizedBox(width: AppSpacing.md),
              _info(Icons.timer_outlined,
                  Formatters.durationSeconds(attempt.durationSeconds)),
              const Spacer(),
              Text(
                Formatters.relative(attempt.submittedAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}