import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_course.dart';

class AdminCourseDetailsPage extends StatefulWidget {
  const AdminCourseDetailsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<AdminCourseDetailsPage> createState() =>
      _AdminCourseDetailsPageState();
}

class _AdminCourseDetailsPageState
    extends State<AdminCourseDetailsPage> {
  MockCourse? _course;

  @override
  void initState() {
    super.initState();
    _course = _find();
  }

  MockCourse? _find() {
    for (final c in MockCourses.all) {
      if (c.id == widget.courseId) return c;
    }
    return null;
  }

  Future<void> _archive() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Archive course?',
      message:
      '"${_course!.title}" will be hidden from students and marked as '
          'archived. You can restore it later.',
      confirmLabel: 'Archive',
      isDestructive: true,
      icon: Icons.archive_outlined,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _course = _course!.copyWith(status: CourseStatus.archived);
    });
    AppSnackbar.showSuccess(context, 'Course archived (mock).');
  }

  @override
  Widget build(BuildContext context) {
    final c = _course;
    if (c == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Course not found')),
      );
    }

    final sections = MockSections.byCourse(c.id);
    final quizzes = MockQuizzes.byCourse(c.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Course Details')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _hero(c),
            const SizedBox(height: AppSpacing.md),
            _summary(c),
            const SizedBox(height: AppSpacing.lg),

            _sectionTitle('Instructor'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Name', c.instructorName),
              _infoRow('Instructor ID', c.instructorId),
            ]),
            const SizedBox(height: AppSpacing.lg),

            _sectionTitle('Classification'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Category', c.categoryName),
              _infoRow('Level', c.level.label),
              _infoRow('Price',
                  c.price == 0 ? 'Free' : '\$${c.price.toStringAsFixed(2)}'),
            ]),
            const SizedBox(height: AppSpacing.lg),

            _sectionTitle('Structure'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Sections', '${sections.length}'),
              _infoRow('Lessons', '${c.lessonCount}'),
              _infoRow('Quizzes', '${quizzes.length}'),
              _infoRow('Duration',
                  Formatters.duration(c.totalDurationMinutes)),
            ]),
            const SizedBox(height: AppSpacing.lg),

            _sectionTitle('Performance'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Learners',
                  Formatters.count(c.learnerCount)),
              _infoRow('Rating',
                  '${c.rating.toStringAsFixed(1)} (${c.ratingCount})'),
            ]),
            const SizedBox(height: AppSpacing.lg),

            _sectionTitle('Metadata'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Course ID', c.id),
              if (c.createdAt != null)
                _infoRow('Created', Formatters.date(c.createdAt)),
              if (c.updatedAt != null)
                _infoRow('Updated', Formatters.date(c.updatedAt)),
            ]),
            const SizedBox(height: AppSpacing.xl),

            if (c.status != CourseStatus.archived)
              AppButton.danger(
                label: 'Archive Course',
                icon: Icons.archive_outlined,
                onPressed: _archive,
              ),
          ],
        ),
      ),
    );
  }

  Widget _hero(MockCourse c) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: SizedBox(
              height: 64,
              width: 64,
              child: (c.thumbnailUrl != null &&
                  c.thumbnailUrl!.isNotEmpty)
                  ? Image.network(
                c.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _thumb(),
              )
                  : _thumb(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: AppTextStyles.headingSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(c.categoryName, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb() => Container(
    color: AppColors.primarySurface,
    child: const Icon(
      Icons.play_circle_outline_rounded,
      size: 30,
      color: AppColors.primary,
    ),
  );

  Widget _summary(MockCourse c) {
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
              Text('Status', style: AppTextStyles.labelMedium),
              const Spacer(),
              switch (c.status) {
                CourseStatus.draft =>
                const AppStatusChip(status: AppStatus.draft),
                CourseStatus.published =>
                const AppStatusChip(status: AppStatus.published),
                CourseStatus.archived =>
                const AppStatusChip(status: AppStatus.archived),
              },
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Description', style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(c.description, style: AppTextStyles.bodySmall),
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