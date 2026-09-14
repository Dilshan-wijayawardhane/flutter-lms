import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/mock_reviews.dart';
import '../../../../mock_data/mock_stats.dart';
import '../../../../mock_data/mock_users.dart';
import '../../../../mock_data/models/mock_course.dart';
import '../../../../mock_data/models/mock_user.dart';
import '../widgets/admin_dashboard_section.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/user_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockUsers.admin1;
    final stats = MockStats.admin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              _header(context, profile.fullName),
              const SizedBox(height: AppSpacing.md),
              _statsGrid(stats),
              const SizedBox(height: AppSpacing.md),
              _quickActions(context),
              AdminDashboardSection(
                title: 'Recent Users',
                actionLabel: 'See all',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminUsers),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: MockUsers.all
                        .take(3)
                        .map((u) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: UserCard(
                        user: u,
                        onTap: () =>
                            Navigator.of(context).pushNamed(
                              AppRoutes.adminUserDetails,
                              arguments: u.id,
                            ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
              AdminDashboardSection(
                title: 'Recent Courses',
                actionLabel: 'See all',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminCourses),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: MockCourses.all
                        .take(3)
                        .map((c) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: _courseRow(context, c),
                    ))
                        .toList(),
                  ),
                ),
              ),
              AdminDashboardSection(
                title: 'Recent Reviews',
                actionLabel: 'Moderate',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminReviews),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: MockReviews.all
                        .take(3)
                        .map((r) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: _reviewRow(r),
                    ))
                        .toList(),
                  ),
                ),
              ),
              AdminDashboardSection(
                title: 'Recent Submissions',
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: MockSubmissions.all
                        .take(3)
                        .map((s) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: _submissionRow(s),
                    ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: AppTextStyles.headingMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Platform administrator',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          AppAvatar(
            name: name,
            size: AppSpacing.avatarMd,
            borderWidth: 2,
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(stats) {
    final tiles = [
      AdminStatCard(
        label: 'Total Users',
        value: '${stats.totalUsers}',
        icon: Icons.people_alt_outlined,
        color: AppColors.primary,
        subtitle: '${stats.activeUsers} active',
      ),
      AdminStatCard(
        label: 'Students',
        value: '${stats.totalStudents}',
        icon: Icons.school_outlined,
        color: AppColors.info,
      ),
      AdminStatCard(
        label: 'Instructors',
        value: '${stats.totalInstructors}',
        icon: Icons.co_present_outlined,
        color: AppColors.warning,
      ),
      AdminStatCard(
        label: 'Suspended',
        value: '${stats.suspendedUsers}',
        icon: Icons.block_outlined,
        color: AppColors.danger,
      ),
      AdminStatCard(
        label: 'Courses',
        value: '${stats.totalCourses}',
        icon: Icons.menu_book_outlined,
        color: AppColors.primary,
        subtitle: '${stats.publishedCourses} published',
      ),
      AdminStatCard(
        label: 'Enrollments',
        value: Formatters.count(stats.totalEnrollments),
        icon: Icons.how_to_reg_outlined,
        color: AppColors.success,
      ),
      AdminStatCard(
        label: 'Reviews',
        value: '${stats.totalReviews}',
        icon: Icons.rate_review_outlined,
        color: AppColors.info,
        subtitle: '${stats.hiddenReviews} hidden',
      ),
      AdminStatCard(
        label: 'Draft Courses',
        value: '${stats.draftCourses}',
        icon: Icons.edit_outlined,
        color: AppColors.warning,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.5,
        children: tiles,
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.people_alt_outlined,
        label: 'Users',
        color: AppColors.primary,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.adminUsers),
      ),
      _QuickAction(
        icon: Icons.menu_book_outlined,
        label: 'Courses',
        color: AppColors.info,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.adminCourses),
      ),
      _QuickAction(
        icon: Icons.category_outlined,
        label: 'Categories',
        color: AppColors.warning,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.adminCategories),
      ),
      _QuickAction(
        icon: Icons.rate_review_outlined,
        label: 'Reviews',
        color: AppColors.success,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.adminReviews),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: actions
            .map((a) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: a == actions.last ? 0 : AppSpacing.xs,
            ),
            child: _quickActionTile(a),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _quickActionTile(_QuickAction a) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: a.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(a.icon, color: a.color, size: 22),
              const SizedBox(height: 4),
              Text(
                a.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _courseRow(BuildContext context, MockCourse c) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.adminCourseDetails,
          arguments: c.id,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(c.instructorName,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text(
                '${c.learnerCount}',
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewRow(review) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(name: review.studentName, size: 36),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(review.studentName,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Row(
                      children: List.generate(
                        review.rating,
                            (_) => const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: AppColors.star,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  review.comment,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submissionRow(submission) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(name: submission.studentName, size: 36),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(submission.studentName,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(submission.assignmentTitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            Formatters.relative(submission.submittedAt),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}