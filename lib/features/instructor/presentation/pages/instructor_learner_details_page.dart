import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../student/data/models/enrollment.dart';
import '../../providers/instructor_course_provider.dart';
import '../../providers/instructor_learner_provider.dart';

class InstructorLearnerDetailsPage extends StatelessWidget {
  const InstructorLearnerDetailsPage({
    super.key,
    required this.enrollmentId,
  });

  final String enrollmentId;

  @override
  Widget build(BuildContext context) {
    final enrollments = context.watch<InstructorLearnerProvider>();
    final courses =
        context.watch<InstructorCourseProvider>().courses;

    Enrollment? e;
    for (final c in courses) {
      for (final x in enrollments.enrollmentsFor(c.id)) {
        if (x.id == enrollmentId) {
          e = x;
          break;
        }
      }
      if (e != null) break;
    }

    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Enrollment not found')),
      );
    }

    final name = e.studentName ?? e.studentId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learner')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _header(name, e),
            const SizedBox(height: AppSpacing.lg),
            Text('Progress', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            _progressCard(e),
            const SizedBox(height: AppSpacing.lg),
            Text('Enrollment', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Course', e.courseName),
              _infoRow('Enrolled', Formatters.date(e.enrolledAt)),
              _infoRow('Last accessed',
                  Formatters.relative(e.lastAccessedAt)),
              _infoRow('Status', e.status.name.toUpperCase()),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _header(String name, Enrollment e) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(name: name, size: 56, borderWidth: 2),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Text(e.studentId, style: AppTextStyles.caption),
                const SizedBox(height: 6),
                const AppStatusChip(status: AppStatus.active),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(Enrollment e) {
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
            borderRadius:
            BorderRadius.circular(AppSpacing.radiusPill),
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
            '${e.completedLessonCount} of ${e.totalLessonCount} lessons',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

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