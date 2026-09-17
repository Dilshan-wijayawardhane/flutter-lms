import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../providers/quiz_provider.dart';

class StudentQuizResultPage extends StatefulWidget {
  const StudentQuizResultPage({super.key, required this.quizId});

  final String quizId;

  @override
  State<StudentQuizResultPage> createState() =>
      _StudentQuizResultPageState();
}

class _StudentQuizResultPageState extends State<StudentQuizResultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadAttempts(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final quiz = p.quizById(widget.quizId);
    final attempts = p.attemptsFor(widget.quizId);
    final latest = attempts.isEmpty ? null : attempts.first;

    if (quiz == null && latest == null) {
      return const Scaffold(
        body: SafeArea(
          child: AppLoading(message: 'Loading result…'),
        ),
      );
    }

    final score = latest?.score ?? 0;
    final total = latest?.totalPoints ?? quiz?.totalPoints ?? 0;
    final percent =
    total > 0 ? (score / total) * 100 : 0.0;
    final passed = latest?.passed ?? (percent >= (quiz?.passingScore ?? 60));

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
            _hero(context, quiz, score, total, percent, passed),
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: 'View Attempt History',
              icon: Icons.history_rounded,
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.studentQuizAttempts,
                arguments: widget.quizId,
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

  Widget _hero(
      BuildContext context,
      dynamic quiz,
      int score,
      int total,
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
            quiz?.title ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat('Score', '$score/$total'),
              _stat('Percent', '${percent.toStringAsFixed(0)}%'),
              _stat('Passing',
                  '${(quiz?.passingScore ?? 60)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headingSmall),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}