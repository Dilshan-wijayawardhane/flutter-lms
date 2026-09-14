import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_course.dart';
import '../../../../mock_data/models/mock_lesson.dart';
import '../../../../mock_data/models/mock_section.dart';

class StudentCourseDetailsPage extends StatelessWidget {
  const StudentCourseDetailsPage({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final course = _findCourse(courseId);
    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Course not found')),
      );
    }
    final sections = MockSections.byCourse(course.id);
    final enrolled = course.isEnrolled;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            _heroAppBar(context, course),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleBlock(course),
                    const SizedBox(height: AppSpacing.md),
                    _metaRow(course),
                    const SizedBox(height: AppSpacing.md),
                    _instructorRow(course),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionTitle('About this course'),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      course.description,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionTitle('Curriculum'),
                    const SizedBox(height: AppSpacing.xs),
                    _curriculum(context, sections, course),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomCta(context, course, enrolled),
    );
  }

  MockCourse? _findCourse(String id) {
    for (final c in MockCourses.all) {
      if (c.id == id) return c;
    }
    return null;
  }

  Widget _heroAppBar(BuildContext context, MockCourse course) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: (course.thumbnailUrl != null &&
            course.thumbnailUrl!.isNotEmpty)
            ? Image.network(
          course.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _heroPlaceholder(),
        )
            : _heroPlaceholder(),
      ),
    );
  }

  Widget _heroPlaceholder() => Container(
    color: AppColors.primary,
    child: const Center(
      child: Icon(
        Icons.play_circle_outline_rounded,
        size: 72,
        color: Colors.white,
      ),
    ),
  );

  Widget _titleBlock(MockCourse course) {
    return Text(course.title, style: AppTextStyles.headingLarge);
  }

  Widget _metaRow(MockCourse course) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        _chip(Icons.star_rounded, course.rating.toStringAsFixed(1)),
        _chip(
          Icons.people_alt_outlined,
          '${Formatters.count(course.learnerCount)} learners',
        ),
        _chip(Icons.menu_book_outlined, '${course.lessonCount} lessons'),
        _chip(
          Icons.timer_outlined,
          Formatters.duration(course.totalDurationMinutes),
        ),
        _chip(Icons.signal_cellular_alt_rounded, course.level.label),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _instructorRow(MockCourse course) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySurface,
            child: Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instructor', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  course.instructorName,
                  style: AppTextStyles.labelLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.headingSmall);
  }

  Widget _curriculum(
      BuildContext context,
      List<MockSection> sections,
      MockCourse course,
      ) {
    if (sections.isEmpty) {
      return Text(
        'Curriculum will be available soon.',
        style: AppTextStyles.bodySmall,
      );
    }
    return Column(
      children: sections.map((s) {
        final lessons = MockLessons.bySection(s.id);
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              childrenPadding:
              const EdgeInsets.only(bottom: AppSpacing.sm),
              title: Text(s.title, style: AppTextStyles.labelLarge),
              subtitle: Text(
                '${lessons.length} lessons',
                style: AppTextStyles.caption,
              ),
              children: lessons.map((l) => _lessonTile(l)).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _lessonTile(MockLesson lesson) {
    return ListTile(
      dense: true,
      leading: Icon(
        _lessonIcon(lesson.type),
        color: AppColors.primary,
        size: 20,
      ),
      title: Text(lesson.title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        '${lesson.type.label} · ${Formatters.duration(lesson.durationMinutes)}',
        style: AppTextStyles.caption,
      ),
    );
  }

  IconData _lessonIcon(LessonType t) {
    switch (t) {
      case LessonType.text:
        return Icons.article_outlined;
      case LessonType.video:
        return Icons.play_circle_outline_rounded;
      case LessonType.document:
        return Icons.description_outlined;
    }
  }

  Widget _bottomCta(
      BuildContext context,
      MockCourse course,
      bool enrolled,
      ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: enrolled
            ? AppButton.primary(
          label: 'Continue Learning',
          icon: Icons.play_arrow_rounded,
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.studentLearning,
            arguments: course.id,
          ),
        )
            : AppButton.primary(
          label: course.price == 0
              ? 'Enroll for Free'
              : 'Enroll · \$${course.price.toStringAsFixed(2)}',
          icon: Icons.how_to_reg_outlined,
          onPressed: () {
            AppSnackbar.showSuccess(
              context,
              'Enrolled in "${course.title}" (mock)',
            );
          },
        ),
      ),
    );
  }
}