import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_course.dart';
import '../../../../mock_data/models/mock_lesson.dart';
import '../../../../mock_data/models/mock_quiz.dart';
import '../../../../mock_data/models/mock_section.dart';
import '../widgets/lesson_card.dart';

class StudentLearningPage extends StatefulWidget {
  const StudentLearningPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<StudentLearningPage> createState() => _StudentLearningPageState();
}

class _StudentLearningPageState extends State<StudentLearningPage> {
  int _expandedSectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final course = _findCourse(widget.courseId);
    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Course not found')),
      );
    }

    final sections = MockSections.byCourse(course.id);
    final quizzes = MockQuizzes.byCourse(course.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          course.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _progressHeader(course),
            const SizedBox(height: AppSpacing.lg),
            Text('Curriculum', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            if (sections.isEmpty)
              const AppEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No sections yet',
                message:
                'This course does not have any sections published yet.',
              )
            else
              ...List.generate(sections.length, (i) {
                return _sectionBlock(sections[i], i);
              }),
            if (quizzes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Quizzes', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              ...quizzes.map(_quizTile),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  MockCourse? _findCourse(String id) {
    for (final c in MockCourses.all) {
      if (c.id == id) return c;
    }
    return null;
  }

  Widget _progressHeader(MockCourse course) {
    final value = (course.progressPercent / 100).clamp(0.0, 1.0);
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
              Expanded(
                child: Text(
                  'Your progress',
                  style: AppTextStyles.labelLarge,
                ),
              ),
              Text(
                '${course.progressPercent}%',
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
            'Progress is a mock value in this phase. Real progress will '
                'come from the backend.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _sectionBlock(MockSection section, int index) {
    final lessons = MockLessons.bySection(section.id);
    final expanded = _expandedSectionIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: () => setState(
                  () => _expandedSectionIndex = expanded ? -1 : index,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${section.title}',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${lessons.length} lessons',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                children: List.generate(lessons.length, (i) {
                  final lesson = lessons[i];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.xs,
                    ),
                    child: LessonCard(
                      lesson: lesson,
                      index: i + 1,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.studentLesson,
                        arguments: lesson.id,
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quizTile(MockQuiz quiz) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius:
                BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quiz.title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${quiz.questionCount} questions · '
                        '${quiz.durationMinutes} min · Pass ${quiz.passingScore}%',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            AppButton.primary(
              label: 'Start',
              isFullWidth: false,
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.studentQuiz,
                arguments: quiz.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}