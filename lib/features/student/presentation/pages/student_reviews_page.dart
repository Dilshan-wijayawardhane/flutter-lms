import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_reviews.dart';
import '../../../../mock_data/models/mock_review.dart';
import '../widgets/review_card.dart';

class StudentReviewsPage extends StatefulWidget {
  const StudentReviewsPage({super.key});

  @override
  State<StudentReviewsPage> createState() => _StudentReviewsPageState();
}

class _StudentReviewsPageState extends State<StudentReviewsPage> {
  // Local mutable copy so delete/edit actions demonstrate in this phase.
  late List<MockReview> _reviews;

  static const _myId = 'user_student_001';

  @override
  void initState() {
    super.initState();
    _reviews = List.of(MockReviews.all);
  }

  Future<void> _delete(MockReview review) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete review?',
      message: 'This will permanently remove your review.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _reviews.removeWhere((r) => r.id == review.id));
    AppSnackbar.showSuccess(context, 'Review deleted (mock).');
  }

  void _edit(MockReview review) {
    AppSnackbar.showInfo(
      context,
      'Edit review UI comes in the backend integration phase.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mine =
    _reviews.where((r) => r.studentId == _myId).toList();
    final others =
    _reviews.where((r) => r.studentId != _myId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reviews')),
      body: SafeArea(
        top: false,
        child: _reviews.isEmpty
            ? const AppEmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          message: 'Reviews will appear here once courses are rated.',
        )
            : ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (mine.isNotEmpty) ...[
              Text('Your reviews',
                  style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              ...mine.map((r) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.sm,
                ),
                child: ReviewCard(
                  review: r,
                  isOwn: true,
                  onEdit: () => _edit(r),
                  onDelete: () => _delete(r),
                ),
              )),
              const SizedBox(height: AppSpacing.md),
            ],
            if (others.isNotEmpty) ...[
              Text('All reviews',
                  style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              ...others.map((r) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.sm,
                ),
                child: ReviewCard(review: r),
              )),
            ],
          ],
        ),
      ),
    );
  }
}