import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../student/data/models/course.dart';
import '../../../student/providers/instructor_course_provider.dart';
import '../../../student/providers/profile_provider.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/instructor_course_card.dart';
import '../widgets/stat_card.dart';

class InstructorDashboardPage extends StatefulWidget {
  const InstructorDashboardPage({super.key});

  @override
  State<InstructorDashboardPage> createState() =>
      _InstructorDashboardPageState();
}

class _InstructorDashboardPageState
    extends State<InstructorDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>();
      if (!profile.hasProfile) profile.load();

      final courses = context.read<InstructorCourseProvider>();
      if (courses.listState != LoadState.success) {
        courses.loadMyCourses();
      }
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ProfileProvider>().load(force: true),
      context
          .read<InstructorCourseProvider>()
          .loadMyCourses(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final coursesProv = context.watch<InstructorCourseProvider>();
    final courses = coursesProv.courses;

    final published =
    courses.where((c) => c.status == CourseStatus.published).toList();
    final drafts =
    courses.where((c) => c.status == CourseStatus.draft).toList();
    final archived =
    courses.where((c) => c.status == CourseStatus.archived).toList();
    final totalLearners =
    courses.fold<int>(0, (sum, c) => sum + c.learnerCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              _header(profile?.fullName ?? 'Instructor'),
              const SizedBox(height: AppSpacing.md),
              _statsGrid(
                total: courses.length,
                published: published.length,
                drafts: drafts.length,
                archived: archived.length,
                learners: totalLearners,
              ),
              const SizedBox(height: AppSpacing.md),
              _quickActions(context),
              InstructorDashboardSection(
                title: 'My Courses',
                actionLabel: 'See all',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.instructorCourses),
                child: courses.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('No courses yet'),
                )
                    : Padding(
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
                        onTap: () => Navigator.of(context)
                            .pushNamed(
                          AppRoutes
                              .instructorCourseDetails,
                          arguments: c.id,
                        ),
                      ),
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
                  child: _performanceCard(
                    published: published.length,
                    drafts: drafts.length,
                    archived: archived.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String name) {
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

  Widget _statsGrid({
    required int total,
    required int published,
    required int drafts,
    required int archived,
    required int learners,
  }) {
    final tiles = [
      StatCard(
        label: 'Total Courses',
        value: '$total',
        icon: Icons.menu_book_outlined,
        color: AppColors.primary,
        subtitle: '$published published',
      ),
      StatCard(
        label: 'Learners',
        value: Formatters.count(learners),
        icon: Icons.people_alt_outlined,
        color: AppColors.info,
      ),
      StatCard(
        label: 'Drafts',
        value: '$drafts',
        icon: Icons.edit_outlined,
        color: AppColors.warning,
      ),
      StatCard(
        label: 'Archived',
        value: '$archived',
        icon: Icons.archive_outlined,
        color: AppColors.textTertiary,
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
        icon: Icons.menu_book_outlined,
        label: 'My Courses',
        color: AppColors.info,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorCourses),
      ),
      _QuickAction(
        icon: Icons.people_alt_outlined,
        label: 'Learners',
        color: AppColors.success,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorEnrollments),
      ),
      _QuickAction(
        icon: Icons.assignment_outlined,
        label: 'Assignments',
        color: AppColors.warning,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.instructorAssignments),
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

  Widget _performanceCard({
    required int published,
    required int drafts,
    required int archived,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _perfRow('Published', '$published', AppColors.success),
          const Divider(height: AppSpacing.lg),
          _perfRow('Drafts', '$drafts', AppColors.warning),
          const Divider(height: AppSpacing.lg),
          _perfRow('Archived', '$archived', AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _perfRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const Spacer(),
        Text(value,
            style: AppTextStyles.labelLarge.copyWith(color: color)),
      ],
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