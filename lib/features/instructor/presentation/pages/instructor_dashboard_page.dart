import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/mock_stats.dart';
import '../../../../mock_data/mock_users.dart';
import '../../../../mock_data/models/mock_course.dart';
import '../../../../mock_data/models/mock_submission.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/instructor_course_card.dart';
import '../widgets/stat_card.dart';

class InstructorDashboardPage extends StatelessWidget {
  const InstructorDashboardPage({super.key});

  static const _instructorId = 'user_instructor_001';

  @override
  Widget build(BuildContext context) {
    final profile = MockUsers.instructorProfile1;
    final stats = MockStats.instructor;
    final myCourses = MockCourses.byInstructor(_instructorId);
    final published = myCourses
        .where((c) => c.status == CourseStatus.published)
        .toList();
    final recentSubmissions = MockSubmissions.all
        .where((s) =>
    s.status == SubmissionStatus.submitted ||
        s.status == SubmissionStatus.resubmissionRequired)
        .take(3)
        .toList();

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
              InstructorDashboardSection(
                title: 'My Courses',
                actionLabel: 'See all',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.instructorCourses),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: published
                        .take(3)
                        .map((c) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: InstructorCourseCard(
                        course: c,
                        onTap: () =>
                            Navigator.of(context).pushNamed(
                              AppRoutes.instructorCourseDetails,
                              arguments: c.id,
                            ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
              InstructorDashboardSection(
                title: 'Recent Submissions',
                actionLabel: 'See all',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.instructorSubmissions),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: recentSubmissions.isEmpty
                      ? _emptyRow('No recent submissions')
                      : Column(
                    children: recentSubmissions
                        .map((s) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: _submissionRow(context, s),
                    ))
                        .toList(),
                  ),
                ),
              ),
              InstructorDashboardSection(
                title: 'Course Performance',
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: _performanceCard(stats),
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
              ],
            ),
          ),
          AppAvatar(name: name, size: AppSpacing.avatarMd),
        ],
      ),
    );
  }

  Widget _statsGrid(stats) {
    final tiles = [
      StatCard(
        label: 'Total Courses',
        value: '${stats.totalCourses}',
        icon: Icons.menu_book_outlined,
        color: AppColors.primary,
        subtitle: '${stats.publishedCourses} published',
      ),
      StatCard(
        label: 'Learners',
        value: Formatters.count(stats.totalLearners),
        icon: Icons.people_alt_outlined,
        color: AppColors.info,
        subtitle: '${stats.activeEnrollments} active',
      ),
      StatCard(
        label: 'Pending',
        value: '${stats.pendingSubmissions}',
        icon: Icons.assignment_outlined,
        color: AppColors.warning,
        subtitle: 'submissions',
      ),
      StatCard(
        label: 'Rating',
        value: stats.averageCourseRating.toStringAsFixed(1),
        icon: Icons.star_outline_rounded,
        color: AppColors.success,
        subtitle: 'average',
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
        childAspectRatio: 1.45,
        children: tiles,
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_circle_outline_rounded,
        label: 'New Course',
        color: AppColors.primary,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorCreateCourse),
      ),
      _QuickAction(
        icon: Icons.quiz_outlined,
        label: 'Quizzes',
        color: AppColors.info,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorQuizzes),
      ),
      _QuickAction(
        icon: Icons.assignment_outlined,
        label: 'Assignments',
        color: AppColors.warning,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorAssignments),
      ),
      _QuickAction(
        icon: Icons.people_alt_outlined,
        label: 'Learners',
        color: AppColors.success,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorEnrollments),
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

  Widget _submissionRow(BuildContext context, submission) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(name: submission.studentName, size: 32),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission.studentName,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  submission.assignmentTitle,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppButton.text(
            label: 'Review',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.instructorSubmissionDetails,
              arguments: submission.id,
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceCard(stats) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _perfRow('Draft courses', '${stats.draftCourses}',
              AppColors.warning),
          const Divider(height: AppSpacing.lg),
          _perfRow('Published courses', '${stats.publishedCourses}',
              AppColors.success),
          const Divider(height: AppSpacing.lg),
          _perfRow('Archived courses', '${stats.archivedCourses}',
              AppColors.textTertiary),
          const Divider(height: AppSpacing.lg),
          _perfRow('Recent quiz attempts', '${stats.recentQuizAttempts}',
              AppColors.info),
          const Divider(height: AppSpacing.lg),
          _perfRow(
            'Total revenue',
            '\$${stats.totalRevenue.toStringAsFixed(2)}',
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _perfRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _emptyRow(String text) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    alignment: Alignment.center,
    child: Text(text, style: AppTextStyles.caption),
  );
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