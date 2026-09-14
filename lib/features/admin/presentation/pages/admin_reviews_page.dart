import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_reviews.dart';
import '../../../../mock_data/models/mock_review.dart';
import '../widgets/review_moderation_card.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  late List<MockReview> _reviews;
  int _tab = 0; // 0=All, 1=Visible, 2=Hidden

  @override
  void initState() {
    super.initState();
    _reviews = List.of(MockReviews.all);
  }

  List<MockReview> get _filtered {
    switch (_tab) {
      case 1:
        return _reviews
            .where((r) => r.visibility == ReviewVisibility.visible)
            .toList();
      case 2:
        return _reviews
            .where((r) => r.visibility == ReviewVisibility.hidden)
            .toList();
      default:
        return _reviews;
    }
  }

  Future<void> _setVisibility(
      MockReview review,
      ReviewVisibility next,
      ) async {
    final isHiding = next == ReviewVisibility.hidden;
    final action = isHiding ? 'Hide' : 'Show';
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: '$action review?',
      message: isHiding
          ? 'The review will be hidden from the course page.'
          : 'The review will become visible on the course page.',
      confirmLabel: action,
      isDestructive: isHiding,
      icon: isHiding
          ? Icons.visibility_off_rounded
          : Icons.visibility_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      final i = _reviews.indexWhere((r) => r.id == review.id);
      if (i != -1) {
        _reviews[i] = _reviews[i].copyWith(visibility: next);
      }
    });
    AppSnackbar.showSuccess(context, '$action successful (mock).');
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reviews'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Row(
              children: [
                _chip('All', 0),
                const SizedBox(width: AppSpacing.xs),
                _chip('Visible', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Hidden', 2),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: list.isEmpty
            ? const AppEmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews found',
          message:
          'Reviews will appear here as students rate courses.',
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final r = list[i];
            return ReviewModerationCard(
              review: r,
              onHide: r.visibility == ReviewVisibility.visible
                  ? () => _setVisibility(
                r,
                ReviewVisibility.hidden,
              )
                  : null,
              onShow: r.visibility == ReviewVisibility.hidden
                  ? () => _setVisibility(
                r,
                ReviewVisibility.visible,
              )
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _chip(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color:
          active ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}