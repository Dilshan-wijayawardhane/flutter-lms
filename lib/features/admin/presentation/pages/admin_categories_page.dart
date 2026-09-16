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
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/providers/category_provider.dart' hide LoadState;
import '../widgets/category_card.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() =>
      _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<CategoryProvider>();
      if (p.state != LoadState.success) p.load();
    });
  }

  List<dynamic> _filtered(CategoryProvider p) {
    switch (_tab) {
      case 1:
        return p.categories.where((c) => c.isActive).toList();
      case 2:
        return p.categories.where((c) => !c.isActive).toList();
      default:
        return p.categories;
    }
  }

  Future<void> _toggle(dynamic cat) async {
    final action = cat.isActive ? 'Deactivate' : 'Activate';
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: '$action category?',
      message: cat.isActive
          ? '"${cat.name}" will no longer be selectable.'
          : '"${cat.name}" will become available for new courses.',
      confirmLabel: action,
      isDestructive: cat.isActive,
      icon: cat.isActive
          ? Icons.toggle_off_outlined
          : Icons.toggle_on_outlined,
    );
    if (!confirmed || !mounted) return;
    final ok = await context
        .read<CategoryProvider>()
        .setActive(cat.id, !cat.isActive);
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? '$action successful.' : 'Could not update.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CategoryProvider>();
    final list = _filtered(p);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categories'),
        automaticallyImplyLeading: false,
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
                _chip('Active', 1),
                const SizedBox(width: AppSpacing.xs),
                _chip('Inactive', 2),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: p.state == LoadState.loading && p.categories.isEmpty
            ? const AppLoading(message: 'Loading categories…')
            : p.state == LoadState.error && p.categories.isEmpty
            ? AppErrorState(
          title: 'Could not load categories',
          message: p.errorMessage ?? 'Please try again.',
          onRetry: () => p.load(force: true),
        )
            : list.isEmpty
            ? AppEmptyState(
          icon: Icons.category_outlined,
          title: 'No categories',
          message: 'Create the first category.',
          actionLabel: 'Create Category',
          onAction: () => Navigator.of(context)
              .pushNamed(AppRoutes.adminCreateCategory),
        )
            : RefreshIndicator(
          onRefresh: () => p.load(force: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: list.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final c = list[i];
              return CategoryCard(
                category: c,
                onEdit: () => Navigator.of(context)
                    .pushNamed(
                  AppRoutes.adminEditCategory,
                  arguments: c.id,
                ),
                onToggleActive: () => _toggle(c),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .pushNamed(AppRoutes.adminCreateCategory),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Category'),
      ),
    );
  }

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