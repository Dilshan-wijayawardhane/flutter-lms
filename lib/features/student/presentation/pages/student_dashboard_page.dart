import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../data/models/course.dart' as api;
import '../../data/models/enrollment.dart';
import '../../providers/course_provider.dart' hide LoadState;
import '../../providers/enrollment_provider.dart' hide LoadState;
import '../../providers/profile_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/progress_card.dart';
import '../widgets/stat_tile.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() =>
      _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>();
      if (!profile.hasProfile) profile.load();

      final enroll = context.read<EnrollmentProvider>();
      if (enroll.state != LoadState.success) enroll.load();

      final courses = context.read<CourseProvider>();
      if (courses.browseState != LoadState.success) courses.browse();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ProfileProvider>().load(force: true),
      context.read<EnrollmentProvider>().load(force: true),
      context.read<CourseProvider>().browse(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final enrollProv = context.watch<EnrollmentProvider>();
    final courseProv = context.watch<CourseProvider>();

    final name = profileProv.profile?.fullName ?? 'Student';
    final enrollments = enrollProv.enrollments;

    Enrollment? current;
    for (final e in enrollments) {
      if (e.status == EnrollmentStatus.active && e.progressPercent < 100) {
        current = e;
        break;
      }
    }

    final enrolledIds = enrollments.map((e) => e.courseId).toSet();
    final recommended = courseProv.courses
        .where((c) => !enrolledIds.contains(c.id) && !c.isEnrolled)
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              _greeting(name),
              const SizedBox(height: AppSpacing.md),
              _statsGrid(enrollments),
              if (current != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    0,
                  ),
                  child: ProgressCard(
                    courseTitle: current.courseName,
                    lessonTitle: 'Continue where you left off',
                    progressPercent: current.progressPercent,
                    onContinue: () => Navigator.of(context).pushNamed(
                      AppRoutes.studentLearning,
                      arguments: current!.courseId,
                    ),
                  ),
                ),
              DashboardSection(
                title: 'My Courses',
                actionLabel: 'See all',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.studentMyCourses),
                child: enrollments.isEmpty
                    ? const _EmptyRow(text: 'No enrollments yet')
                    : SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: enrollments.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final e = enrollments[i];
                      return SizedBox(
                        width: 260,
                        child: CourseCard(
                          course: _toApiCourse(e),
                          showProgress: true,
                          onTap: () =>
                              Navigator.of(context).pushNamed(
                                AppRoutes.studentLearning,
                                arguments: e.courseId,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              DashboardSection(
                title: 'Recommended Courses',
                actionLabel: 'See all',
                onActionTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.studentCourses),
                child: recommended.isEmpty
                    ? const _EmptyRow(
                    text: 'No recommendations available')
                    : Padding(
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

  /// Adapter: turns an Enrollment into a Course so we can reuse CourseCard
  /// without a second network round-trip.
  api.Course _toApiCourse(Enrollment e) {
    return api.Course(
      id: e.courseId,
      title: e.courseName,
      description: '',
      instructorId: '',
      instructorName: e.instructorName ?? '',
      categoryId: '',
      categoryName: '',
      status: api.CourseStatus.published,
      level: api.CourseLevel.beginner,
      thumbnailUrl: e.courseThumbnailUrl,
      progressPercent: e.progressPercent,
      lessonCount: e.totalLessonCount,
      isEnrolled: true,
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
          AppAvatar(name: name, size: AppSpacing.avatarMd),
        ],
      ),
    );
  }

  Widget _statsGrid(List<Enrollment> enrollments) {
    final total = enrollments.length;
    final inProgress = enrollments
        .where((e) => e.status == EnrollmentStatus.active)
        .length;
    final completed = enrollments
        .where((e) => e.status == EnrollmentStatus.completed)
        .length;
    final avgProgress = enrollments.isEmpty
        ? 0
        : (enrollments
        .map((e) => e.progressPercent)
        .reduce((a, b) => a + b) /
        enrollments.length)
        .round();

    final tiles = [
      StatTile(
        label: 'Enrolled',
        value: '$total',
        icon: Icons.menu_book_outlined,
        color: AppColors.primary,
      ),
      StatTile(
        label: 'In Progress',
        value: '$inProgress',
        icon: Icons.timelapse_rounded,
        color: AppColors.info,
      ),
      StatTile(
        label: 'Completed',
        value: '$completed',
        icon: Icons.verified_outlined,
        color: AppColors.success,
      ),
      StatTile(
        label: 'Avg. Progress',
        value: '$avgProgress%',
        icon: Icons.trending_up_rounded,
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
        childAspectRatio: 1.55,
        children: tiles,
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Text(text, style: AppTextStyles.caption),
    );
  }
}