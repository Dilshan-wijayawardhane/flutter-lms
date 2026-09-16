import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../student/data/models/quiz_attempt.dart';
import '../../providers/instructor_quiz_provider.dart';

class InstructorQuizAttemptsPage extends StatefulWidget {
  const InstructorQuizAttemptsPage({super.key, required this.quizId});

  final String quizId;

  @override
  State<InstructorQuizAttemptsPage> createState() =>
      _InstructorQuizAttemptsPageState();
}

class _InstructorQuizAttemptsPageState
    extends State<InstructorQuizAttemptsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorQuizProvider>().loadAttempts(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InstructorQuizProvider>();
    final state = p.attemptsStateFor(widget.quizId);
    final attempts = p.attemptsFor(widget.quizId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quiz Attempts')),
      body: SafeArea(
        top: false,
        child: state == LoadState.loading && attempts.isEmpty
            ? const AppLoading(message: 'Loading attempts…')
            : state == LoadState.error && attempts.isEmpty
            ? AppErrorState(
          title: 'Could not load attempts',
          message: 'Please try again.',
          onRetry: () => p.loadAttempts(
            widget.quizId,
            force: true,
          ),
        )
            : attempts.isEmpty
            ? const AppEmptyState(
          icon: Icons.history_rounded,
          title: 'No attempts yet',
          message:
          'Student attempts will appear here once they take the quiz.',
        )
            : RefreshIndicator(
          onRefresh: () => p.loadAttempts(
            widget.quizId,
            force: true,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: attempts.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) =>
                _attemptCard(attempts[i]),
          ),
        ),
      ),
    );
  }

  Widget _attemptCard(QuizAttempt a) {
    final passed = a.passed ?? false;
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
              AppAvatar(name: a.quizTitle, size: 36),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attempt ${a.attemptNumber}',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.relative(a.submittedAt),
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
                  style:
                  AppTextStyles.labelSmall.copyWith(color: color),
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
                '${a.score ?? '—'}/${a.totalPoints ?? '—'}',
              ),
              _stat(
                'Percent',
                a.scorePercent == null
                    ? '—'
                    : '${a.scorePercent!.toStringAsFixed(0)}%',
              ),
              _stat(
                'Duration',
                Formatters.durationSeconds(a.durationSeconds),
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