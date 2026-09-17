import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../student/data/models/enrollment.dart';
import '../../providers/admin_enrollment_provider.dart';

class AdminEnrollmentDetailsPage extends StatelessWidget {
  const AdminEnrollmentDetailsPage({
    super.key,
    required this.enrollmentId,
  });

  final String enrollmentId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminEnrollmentProvider>();

    Enrollment? found;
    for (final x in provider.enrollments) {
      if (x.id == enrollmentId) {
        found = x;
        break;
      }
    }

    final e = found;
    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const AppEmptyState(
          icon: Icons.how_to_reg_outlined,
          title: 'Enrollment not found',
          message: 'This enrollment is not in the current list.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Enrollment Details')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _header(e),
            const SizedBox(height: AppSpacing.lg),
            Text('Progress', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            _progressCard(e),
            const SizedBox(height: AppSpacing.lg),
            Text('Student', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Name', e.studentName),
              _infoRow('Student ID', e.studentId),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Text('Course', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Course', e.courseName),
              _infoRow('Instructor', e.instructorName ?? '—'),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Text('Timeline', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Enrolled', Formatters.date(e.enrolledAt)),
              _infoRow(
                'Last accessed',
                Formatters.relative(e.lastAccessedAt),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _header(Enrollment e) {
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
                Text(e.courseName, style: AppTextStyles.caption),
                const SizedBox(height: 6),
                _statusChip(e.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.active:
        return const AppStatusChip(status: AppStatus.active);
      case EnrollmentStatus.completed:
        return const AppStatusChip(
          status: AppStatus.published,
          label: 'COMPLETED',
        );
      case EnrollmentStatus.cancelled:
        return const AppStatusChip(
          status: AppStatus.inactive,
          label: 'CANCELLED',
        );
    }
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
              Text('${e.progressPercent}%',
                  style: AppTextStyles.headingSmall
                      .copyWith(color: AppColors.primary)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.labelLarge,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}