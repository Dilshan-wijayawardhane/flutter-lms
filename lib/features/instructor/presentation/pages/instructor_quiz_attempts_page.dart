import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_quiz_attempt.dart';

class InstructorQuizAttemptsPage extends StatelessWidget {
  const InstructorQuizAttemptsPage({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context) {
    final attempts = MockQuizAttempts.byInstructor
        .where((a) => a.quizId == quizId)
        .toList()
      ..sort((a, b) =>
          (b.submittedAt ?? DateTime(0)).compareTo(a.submittedAt ?? DateTime(0)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quiz Attempts')),
      body: SafeArea(
        top: false,
        child: attempts.isEmpty
            ? const AppEmptyState(
          icon: Icons.history_rounded,
          title: 'No attempts yet',
          message:
          'Student attempts will appear here once they take the '
              'quiz.',
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
              AppAvatar(name: attempt.studentName, size: 36),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attempt.studentName,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Attempt ${attempt.attemptNumber} · ${Formatters.relative(attempt.submittedAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
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
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _stat(
                'Score',
                '${attempt.score ?? '—'}/${attempt.totalPoints ?? '—'}',
              ),
              _stat(
                'Percent',
                attempt.scorePercent == null
                    ? '—'
                    : '${attempt.scorePercent!.toStringAsFixed(0)}%',
              ),
              _stat(
                'Duration',
                Formatters.durationSeconds(attempt.durationSeconds),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}