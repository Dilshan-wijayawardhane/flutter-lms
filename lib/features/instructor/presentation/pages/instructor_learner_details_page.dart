import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../mock_data/models/mock_enrollment.dart';

class InstructorLearnerDetailsPage extends StatelessWidget {
  const InstructorLearnerDetailsPage({
    super.key,
    required this.enrollmentId,
  });

  final String enrollmentId;

  @override
  Widget build(BuildContext context) {
    final e = _find();
    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Enrollment not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learner')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _header(e),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle('Progress'),
            const SizedBox(height: AppSpacing.xs),
            _progressCard(e),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle('Enrollment'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Course', e.courseName),
              _infoRow('Enrolled', Formatters.date(e.enrolledAt)),
              _infoRow(
                'Last accessed',
                Formatters.relative(e.lastAccessedAt),
              ),
              _infoRow('Status', e.status.label),
            ]),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle('Activity'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Lessons completed',
                  '${e.completedLessonCount}/${e.totalLessonCount}'),
              _infoRow('Progress', '${e.progressPercent}%'),
            ]),
          ],
        ),
      ),
    );
  }

  MockEnrollment? _find() {
    // In Phase 2, this comes from the backend. For now, we synthesize from
    // the same local data used on the list page.
    final list = _samples();
    for (final e in list) {
      if (e.id == enrollmentId) return e;
    }
    return null;
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
  ];

  Widget _header(MockEnrollment e) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(name: e.studentName, size: 56, borderWidth: 2),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.studentName,
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Text(e.studentId, style: AppTextStyles.caption),
                const SizedBox(height: 6),
                if (e.status == EnrollmentStatus.completed)
                  const AppStatusChip(status: AppStatus.active)
                else
                  const AppStatusChip(status: AppStatus.active),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(MockEnrollment e) {
    final value = (e.progressPercent / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Course progress',
                  style: AppTextStyles.labelMedium),
              const Spacer(),
              Text(
                '${e.progressPercent}%',
                style: AppTextStyles.headingSmall
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
              const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${e.completedLessonCount} of ${e.totalLessonCount} lessons '
                'completed',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: AppTextStyles.headingSmall);

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const Spacer(),
        Text(value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}