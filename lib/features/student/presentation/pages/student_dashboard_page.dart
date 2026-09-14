import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../mock_data/mock_assignments.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/mock_notifications.dart';
import '../../../../mock_data/mock_stats.dart';
import '../../../../mock_data/mock_users.dart';
import '../../../../mock_data/models/mock_course.dart';
import '../../../../mock_data/models/mock_notification.dart';
import '../widgets/course_card.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/progress_card.dart';
import '../widgets/stat_tile.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockUsers.studentProfile1;
    final stats = MockStats.student;
    final enrolled = MockCourses.studentEnrolled;
    final current = enrolled.isNotEmpty ? enrolled.first : null;
    final recommended = MockCourses.published
        .where((c) => !c.isEnrolled)
        .take(4)
        .toList();
    final upcomingAssignments =
    MockAssignments.published.take(3).toList();
    final notifications = MockNotifications.student1.take(3).toList();

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
              _greeting(profile.fullName),
              const SizedBox(height: AppSpacing.md),
              _statsGrid(stats),
              if (current != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    0,
                  ),
                  child: ProgressCard(
                    courseTitle: current.title,
                    lessonTitle: 'Continue where you left off',
                    progressPercent: current.progressPercent,
                    onContinue: () => Navigator.of(context).pushNamed(
                      AppRoutes.studentLearning,
                      arguments: current.id,
                    ),
                  ),
                ),
              DashboardSection(
                title: 'My Courses',
                actionLabel: 'See all',
                onActionTap: () {
                  Navigator.of(context)
                      .pushNamed(AppRoutes.studentMyCourses);
                },
                child: SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: enrolled.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final c = enrolled[i];
                      return SizedBox(
                        width: 260,
                        child: CourseCard(
                          course: c,
                          showProgress: true,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.studentCourseDetails,
                            arguments: c.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              DashboardSection(
                title: 'Upcoming Assignments',
                actionLabel: 'See all',
                onActionTap: () {
                  Navigator.of(context)
                      .pushNamed(AppRoutes.studentAssignments);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: upcomingAssignments
                        .map((a) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: _assignmentRow(context, a.title,
                          a.courseName),
                    ))
                        .toList(),
                  ),
                ),
              ),
              DashboardSection(
                title: 'Recent Notifications',
                actionLabel: 'See all',
                onActionTap: () {
                  Navigator.of(context)
                      .pushNamed(AppRoutes.studentNotifications);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: notifications
                        .map((n) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: _notificationRow(context, n),
                    ))
                        .toList(),
                  ),
                ),
              ),
              DashboardSection(
                title: 'Recommended Courses',
                actionLabel: 'See all',
                onActionTap: () {
                  Navigator.of(context)
                      .pushNamed(AppRoutes.studentCourses);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: recommended
                        .map((c) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: CourseCard(
                        course: c,
                        onTap: () =>
                            Navigator.of(context).pushNamed(
                              AppRoutes.studentCourseDetails,
                              arguments: c.id,
                            ),
                      ),
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

  Widget _greeting(String name) {
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
          AppAvatar(
            name: name,
            size: AppSpacing.avatarMd,
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(stats) {
    final tiles = [
      StatTile(
        label: 'Enrolled',
        value: '${stats.enrolledCourses}',
        icon: Icons.menu_book_outlined,
        color: AppColors.primary,
      ),
      StatTile(
        label: 'In Progress',
        value: '${stats.inProgressCourses}',
        icon: Icons.timelapse_rounded,
        color: AppColors.info,
      ),
      StatTile(
        label: 'Pending',
        value: '${stats.pendingAssignments}',
        icon: Icons.assignment_outlined,
        color: AppColors.warning,
      ),
      StatTile(
        label: 'Avg. Progress',
        value: '${stats.averageProgressPercent}%',
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
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
        childAspectRatio: 1.55,
        children: tiles,
      ),
    );
  }

  Widget _assignmentRow(
      BuildContext context,
      String title,
      String course,
      ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
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
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(course, style: AppTextStyles.caption,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationRow(BuildContext context, MockNotification n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: n.isRead ? AppColors.border : AppColors.primaryLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              _notifIcon(n.type),
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  n.message,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!n.isRead)
            Container(
              height: 8,
              width: 8,
              margin: const EdgeInsets.only(top: 4, left: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  IconData _notifIcon(NotificationType type) {
    switch (type) {
      case NotificationType.course:
        return Icons.menu_book_outlined;
      case NotificationType.assignment:
        return Icons.assignment_outlined;
      case NotificationType.quiz:
        return Icons.quiz_outlined;
      case NotificationType.enrollment:
        return Icons.how_to_reg_outlined;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }
}