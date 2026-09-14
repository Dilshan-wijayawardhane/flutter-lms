import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../mock_data/models/mock_quiz_question.dart';

/// Single multiple-choice question card.
/// Purely presentational — the parent owns selected state.
class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.onSelected,
    this.totalQuestions,
    this.currentIndex,
  });

  final MockQuizQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final int? totalQuestions;
  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentIndex != null && totalQuestions != null) ...[
          Text(
            'Question ${currentIndex! + 1} of $totalQuestions',
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(question.text, style: AppTextStyles.headingSmall),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(question.options.length, (i) {
          final isSelected = selectedIndex == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _option(
              label: question.options[i],
              index: i,
              isSelected: isSelected,
            ),
          );
        }),
      ],
    );
  }

  Widget _option({
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 26,
              width: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Text(
                String.fromCharCode(65 + index), // A, B, C, D
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textPrimary,
                  fontWeight:
                  isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}