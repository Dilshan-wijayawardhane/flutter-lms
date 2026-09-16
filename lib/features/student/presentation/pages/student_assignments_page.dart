import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/submission.dart';
import '../../providers/assignment_provider.dart';
import '../widgets/assignment_card.dart';

class StudentAssignmentsPage extends StatefulWidget {
  const StudentAssignmentsPage({super.key});

  @override
  State<StudentAssignmentsPage> createState() =>
      _StudentAssignmentsPageState();
}

class _StudentAssignmentsPageState extends State<StudentAssignmentsPage> {
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AssignmentProvider>();
      if (p.listState != LoadState.success) p.loadMine();
    });
  }

  List<dynamic> _filtered(AssignmentProvider p) {
    switch (_filter) {
      case 1:
        return p.assignments
            .where((a) => p.submissionFor(a.id) == null ||
            p.submissionFor(a.id)!.status == SubmissionStatus.pending)
            .toList();
      case 2:
        return p.assignments
            .where((a) =>
        p.submissionFor(a.id)?.status ==
            SubmissionStatus.submitted ||
            p.submissionFor(a.id)?.status ==
                SubmissionStatus.resubmissionRequired)
            .toList();
      case 3:
        return p.assignments
            .where((a) => p.submissionFor(a.id)?.status ==
            SubmissionStatus.graded)
            .toList();
      default:
        return p.assignments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assignments'),
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
                _chip('Pending', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Submitted', 2),
                const SizedBox(width: AppSpacing.xs),
                _chip('Graded', 3),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(top: false, child: _buildBody(provider)),
    );
  }

  Widget _buildBody(AssignmentProvider provider) {
    if (provider.listState == LoadState.loading &&
        provider.assignments.isEmpty) {
      return const AppLoading(message: 'Loading assignments…');
    }
    if (provider.listState == LoadState.error &&
        provider.assignments.isEmpty) {
      return AppErrorState(
        title: 'Could not load assignments',
        message: provider.listError ?? 'Please try again.',
        onRetry: () => provider.loadMine(force: true),
      );
    }

    final list = _filtered(provider);
    if (list.isEmpty) {
      return const AppEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No assignments',
        message: 'Assignments for this filter will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadMine(force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final a = list[i];
          return AssignmentCard(
            assignment: a,
            submission: provider.submissionFor(a.id),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.studentAssignmentDetails,
              arguments: a.id,
            ),
          );
        },
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