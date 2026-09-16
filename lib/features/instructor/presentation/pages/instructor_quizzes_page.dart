import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/data/models/quiz.dart';
import '../../providers/instructor_quiz_provider.dart';

class InstructorQuizzesPage extends StatefulWidget {
  const InstructorQuizzesPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorQuizzesPage> createState() =>
      _InstructorQuizzesPageState();
}

class _InstructorQuizzesPageState extends State<InstructorQuizzesPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorQuizProvider>().loadQuizzes(widget.courseId);
    });
  }

  List<Quiz> _filtered(InstructorQuizProvider p) {
    final list = p.quizzesFor(widget.courseId);
    switch (_tab) {
      case 1:
        return list.where((q) => q.status == QuizStatus.draft).toList();
      case 2:
        return list
            .where((q) => q.status == QuizStatus.published)
            .toList();
      default:
        return list;
    }
  }

  Future<void> _delete(Quiz q) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete quiz?',
      message:
      '"${q.title}" and all its questions and attempts will be removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    final ok = await context.read<InstructorQuizProvider>().deleteQuiz(
      courseId: widget.courseId,
      quizId: q.id,
    );
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Quiz deleted.' : 'Could not delete.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstructorQuizProvider>();
    final state = provider.listStateFor(widget.courseId);

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
        child: state == LoadState.loading &&
            provider.quizzesFor(widget.courseId).isEmpty
            ? const AppLoading(message: 'Loading quizzes…')
            : state == LoadState.error
            ? AppErrorState(
          title: 'Could not load quizzes',
          message:
          provider.listErrorFor(widget.courseId) ??
              'Please try again.',
          onRetry: () => provider.loadQuizzes(
            widget.courseId,
            force: true,
          ),
        )
            : _body(provider),
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

  Widget _body(InstructorQuizProvider provider) {
    final list = _filtered(provider);
    if (list.isEmpty) {
      return AppEmptyState(
        icon: Icons.quiz_outlined,
        title: 'No quizzes yet',
        message: 'Create a quiz to assess your students.',
        actionLabel: 'Create Quiz',
        onAction: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorCreateQuiz,
          arguments: widget.courseId,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          provider.loadQuizzes(widget.courseId, force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _card(provider, list[i]),
      ),
    );
  }

  Widget _card(InstructorQuizProvider provider, Quiz q) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.instructorQuestions,
          arguments: {
            'courseId': widget.courseId,
            'quizId': q.id,
          },
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
                    child: Text(q.title,
                        style: AppTextStyles.headingSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (q.status == QuizStatus.published)
                    const AppStatusChip(status: AppStatus.published)
                  else
                    const AppStatusChip(status: AppStatus.draft),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _meta(Icons.help_outline_rounded,
                      '${q.questionCount} questions'),
                  _meta(Icons.timer_outlined, '${q.durationMinutes} min'),
                  _meta(Icons.flag_outlined,
                      'Pass ${q.passingScore}%'),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.instructorEditQuiz,
                      arguments: {
                        'courseId': widget.courseId,
                        'quizId': q.id,
                      },
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.instructorQuizAttempts,
                      arguments: q.id,
                    ),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('Attempts'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _delete(q),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
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