import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../student/providers/profile_provider.dart';
import '../../providers/admin_course_provider.dart';
import '../../providers/admin_user_provider.dart';
import '../widgets/admin_dashboard_section.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/user_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>();
      if (!profile.hasProfile) profile.load();

      context.read<AdminUserProvider>().load();
      context.read<AdminCourseProvider>().load();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ProfileProvider>().load(force: true),
      context.read<AdminUserProvider>().load(force: true),
      context.read<AdminCourseProvider>().load(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final usersP = context.watch<AdminUserProvider>();
    final coursesP = context.watch<AdminCourseProvider>();

    final users = usersP.users;
    final courses = coursesP.courses;

    final students = users
        .where((u) => u.role.toUpperCase() == 'STUDENT')
        .length;
    final instructors = users
        .where((u) => u.role.toUpperCase() == 'INSTRUCTOR')
        .length;
    final active =
        users.where((u) => u.status.toUpperCase() == 'ACTIVE').length;
    final suspended = users
        .where((u) => u.status.toUpperCase() == 'SUSPENDED')
        .length;
    final published = courses
        .where((c) => c.status.name.toUpperCase() == 'PUBLISHED')
        .length;
    final drafts = courses
        .where((c) => c.status.name.toUpperCase() == 'DRAFT')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              _header(profile?.fullName ?? 'Admin'),
              const SizedBox(height: AppSpacing.md),
              _statsGrid(
                users: users.length,
                students: students,
                instructors: instructors,
                active: active,
                suspended: suspended,
                courses: courses.length,
                published: published,
                drafts: drafts,
              ),
              const SizedBox(height: AppSpacing.md),
              _quickActions(context),
              AdminDashboardSection(
                title: 'Recent Users',
                actionLabel: 'See all',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminUsers),
                child: users.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('No users'),
                )
                    : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: users
                        .take(3)
                        .map((u) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: UserCard(
                        user: u,
                        onTap: () => Navigator.of(context)
                            .pushNamed(
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
                child: courses.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('No courses'),
                )
                    : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: courses
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

  Widget _statsGrid({
    required int users,
    required int students,
    required int instructors,
    required int active,
    required int suspended,
    required int courses,
    required int published,
    required int drafts,
  }) {
    final tiles = [
      AdminStatCard(
        label: 'Total Users',
        value: '$users',
        icon: Icons.people_alt_outlined,
        color: AppColors.primary,
        subtitle: '$active active',
      ),
      AdminStatCard(
        label: 'Students',
        value: '$students',
        icon: Icons.school_outlined,
        color: AppColors.info,
      ),
      AdminStatCard(
        label: 'Instructors',
        value: '$instructors',
        icon: Icons.co_present_outlined,
        color: AppColors.warning,
      ),
      AdminStatCard(
        label: 'Suspended',
        value: '$suspended',
        icon: Icons.block_outlined,
        color: AppColors.danger,
      ),
      AdminStatCard(
        label: 'Courses',
        value: '$courses',
        icon: Icons.menu_book_outlined,
        color: AppColors.primary,
        subtitle: '$published published',
      ),
      AdminStatCard(
        label: 'Draft Courses',
        value: '$drafts',
        icon: Icons.edit_outlined,
        color: AppColors.warning,
      ),
      AdminStatCard(
        label: 'Active Users',
        value: '$active',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
      ),
      AdminStatCard(
        label: 'Published',
        value: '$published',
        icon: Icons.publish_outlined,
        color: AppColors.info,
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
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.adminCategories),
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

  Widget _courseRow(BuildContext context, dynamic c) {
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
                Formatters.count(c.learnerCount),
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
        ),
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