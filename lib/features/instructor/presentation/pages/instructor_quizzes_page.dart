import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_quiz.dart';

class InstructorQuizzesPage extends StatefulWidget {
  const InstructorQuizzesPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorQuizzesPage> createState() =>
      _InstructorQuizzesPageState();
}

class _InstructorQuizzesPageState extends State<InstructorQuizzesPage> {
  int _tab = 0; // 0=All, 1=Draft, 2=Published
  late List<MockQuiz> _quizzes;

  @override
  void initState() {
    super.initState();
    _quizzes = List.of(MockQuizzes.byCourse(widget.courseId));
  }

  List<MockQuiz> get _filtered {
    switch (_tab) {
      case 1:
        return _quizzes
            .where((q) => q.status == QuizStatus.draft)
            .toList();
      case 2:
        return _quizzes
            .where((q) => q.status == QuizStatus.published)
            .toList();
      default:
        return _quizzes;
    }
  }

  Future<void> _delete(MockQuiz quiz) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete quiz?',
      message:
      '"${quiz.title}" and all of its questions and attempts will be '
          'removed. This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _quizzes.removeWhere((q) => q.id == quiz.id));
    AppSnackbar.showSuccess(context, 'Quiz deleted (mock).');
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quizzes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Row(
              children: [
                _chip('All', 0),
                const SizedBox(width: AppSpacing.xs),
                _chip('Draft', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Published', 2),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: list.isEmpty
            ? AppEmptyState(
          icon: Icons.quiz_outlined,
          title: _emptyTitle,
          message:
          "Create a quiz to assess your students' understanding.",
          actionLabel: 'Create Quiz',
          onAction: () => Navigator.of(context).pushNamed(
            AppRoutes.instructorCreateQuiz,
            arguments: widget.courseId,
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _quizCard(list[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateQuiz,
          arguments: widget.courseId,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Quiz'),
      ),
    );
  }

  String get _emptyTitle {
    switch (_tab) {
      case 1:
        return 'No draft quizzes';
      case 2:
        return 'No published quizzes';
      default:
        return 'No quizzes yet';
    }
  }

  Widget _quizCard(MockQuiz quiz) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorQuestions,
          arguments: quiz.id,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
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
                      quiz.title,
                      style: AppTextStyles.headingSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (quiz.status == QuizStatus.published)
                    const AppStatusChip(status: AppStatus.published)
                  else
                    const AppStatusChip(status: AppStatus.draft),
                ],
              ),
              if (quiz.description != null &&
                  quiz.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  quiz.description!,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _meta(Icons.help_outline_rounded,
                      '${quiz.questionCount} questions'),
                  _meta(Icons.timer_outlined,
                      '${quiz.durationMinutes} min'),
                  _meta(Icons.flag_outlined,
                      'Pass ${quiz.passingScore}%'),
                  _meta(Icons.repeat_rounded,
                      '${quiz.maxAttempts} attempts'),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.instructorEditQuiz,
                      arguments: quiz.id,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.instructorQuizAttempts,
                      arguments: quiz.id,
                    ),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('Attempts'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _delete(quiz),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String label) => Container(
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

  Widget _chip(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
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