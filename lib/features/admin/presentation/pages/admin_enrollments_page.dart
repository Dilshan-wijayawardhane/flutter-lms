import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../mock_data/models/mock_enrollment.dart';
import '../widgets/enrollment_card.dart';

class AdminEnrollmentsPage extends StatefulWidget {
  const AdminEnrollmentsPage({super.key});

  @override
  State<AdminEnrollmentsPage> createState() =>
      _AdminEnrollmentsPageState();
}

class _AdminEnrollmentsPageState extends State<AdminEnrollmentsPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _filter = 0; // 0=All, 1=Active, 2=Completed, 3=Cancelled

  late final List<MockEnrollment> _all = _samples();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MockEnrollment> _samples() => [
    MockEnrollment(
      id: 'enrollment_001',
      courseId: 'course_001',
      courseName: 'Flutter Fundamentals',
      courseThumbnailUrl: null,
      instructorName: 'Dr. Elena Petrov',
      studentId: 'user_student_001',
      studentName: 'Aisha Rahman',
      status: EnrollmentStatus.active,
      progressPercent: 45,
      enrolledAt: DateTime(2025, 3, 1),
      lastAccessedAt:
      DateTime.now().subtract(const Duration(hours: 3)),
      completedLessonCount: 11,
      totalLessonCount: 24,
    ),
    MockEnrollment(
      id: 'enrollment_002',
      courseId: 'course_001',
      courseName: 'Flutter Fundamentals',
      courseThumbnailUrl: null,
      instructorName: 'Dr. Elena Petrov',
      studentId: 'user_student_002',
      studentName: 'Daniel Okafor',
      status: EnrollmentStatus.active,
      progressPercent: 72,
      enrolledAt: DateTime(2025, 2, 20),
      lastAccessedAt:
      DateTime.now().subtract(const Duration(days: 1)),
      completedLessonCount: 17,
      totalLessonCount: 24,
    ),
    MockEnrollment(
      id: 'enrollment_003',
      courseId: 'course_001',
      courseName: 'Flutter Fundamentals',
      courseThumbnailUrl: null,
      instructorName: 'Dr. Elena Petrov',
      studentId: 'user_student_003',
      studentName: 'Mai Tanaka',
      status: EnrollmentStatus.completed,
      progressPercent: 100,
      enrolledAt: DateTime(2025, 1, 15),
      lastAccessedAt:
      DateTime.now().subtract(const Duration(days: 4)),
      completedLessonCount: 24,
      totalLessonCount: 24,
    ),
    MockEnrollment(
      id: 'enrollment_004',
      courseId: 'course_002',
      courseName: 'Advanced Flutter Architecture',
      courseThumbnailUrl: null,
      instructorName: 'Dr. Elena Petrov',
      studentId: 'user_student_001',
      studentName: 'Aisha Rahman',
      status: EnrollmentStatus.active,
      progressPercent: 12,
      enrolledAt: DateTime(2025, 3, 10),
      lastAccessedAt:
      DateTime.now().subtract(const Duration(hours: 8)),
      completedLessonCount: 5,
      totalLessonCount: 38,
    ),
    MockEnrollment(
      id: 'enrollment_005',
      courseId: 'course_005',
      courseName: 'Fullstack Web Development',
      courseThumbnailUrl: null,
      instructorName: 'Dr. Elena Petrov',
      studentId: 'user_student_004',
      studentName: 'Lucas Silva',
      status: EnrollmentStatus.cancelled,
      progressPercent: 8,
      enrolledAt: DateTime(2025, 2, 10),
      lastAccessedAt:
      DateTime.now().subtract(const Duration(days: 20)),
      completedLessonCount: 2,
      totalLessonCount: 48,
    ),
  ];

  List<MockEnrollment> get _filtered {
    return _all.where((e) {
      final matchesQuery = _query.isEmpty ||
          e.studentName.toLowerCase().contains(_query.toLowerCase()) ||
          e.courseName.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = switch (_filter) {
        1 => e.status == EnrollmentStatus.active,
        2 => e.status == EnrollmentStatus.completed,
        3 => e.status == EnrollmentStatus.cancelled,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Enrollments'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              scrollDirection: Axis.horizontal,
              children: [
                _chip('All', 0),
                const SizedBox(width: AppSpacing.xs),
                _chip('Active', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Completed', 2),
                const SizedBox(width: AppSpacing.xs),
                _chip('Cancelled', 3),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Search enrollments',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const AppEmptyState(
                icon: Icons.how_to_reg_outlined,
                title: 'No enrollments found',
                message:
                'Try a different search or filter to see '
                    'enrollments.',
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final e = list[i];
                  return EnrollmentCard(
                    enrollment: e,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.adminEnrollmentDetails,
                      arguments: e.id,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int index) {
    final active = _filter == index;
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
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