import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_categories.dart';
import '../../../../mock_data/models/mock_category.dart';
import '../widgets/category_card.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  late List<MockCategory> _categories;
  int _tab = 0; // 0=All, 1=Active, 2=Inactive

  @override
  void initState() {
    super.initState();
    _categories = List.of(MockCategories.all);
  }

  List<MockCategory> get _filtered {
    switch (_tab) {
      case 1:
        return _categories.where((c) => c.isActive).toList();
      case 2:
        return _categories.where((c) => !c.isActive).toList();
      default:
        return _categories;
    }
  }

  Future<void> _toggleActive(MockCategory cat) async {
    final action = cat.isActive ? 'Deactivate' : 'Activate';
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: '$action category?',
      message: cat.isActive
          ? '"${cat.name}" will no longer be selectable for new courses.'
          : '"${cat.name}" will become available for new courses.',
      confirmLabel: action,
      isDestructive: cat.isActive,
      icon: cat.isActive
          ? Icons.toggle_off_outlined
          : Icons.toggle_on_outlined,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      final i = _categories.indexWhere((c) => c.id == cat.id);
      if (i != -1) {
        _categories[i] =
            _categories[i].copyWith(isActive: !cat.isActive);
      }
    });
    AppSnackbar.showSuccess(context, '$action successful (mock).');
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

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
        child: list.isEmpty
            ? AppEmptyState(
          icon: Icons.category_outlined,
          title: _emptyTitle,
          message:
          'Categories help organize courses on the platform.',
          actionLabel: 'Create Category',
          onAction: () => Navigator.of(context)
              .pushNamed(AppRoutes.adminCreateCategory),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final c = list[i];
            return CategoryCard(
              category: c,
              onEdit: () => Navigator.of(context).pushNamed(
                AppRoutes.adminEditCategory,
                arguments: c.id,
              ),
              onToggleActive: () => _toggleActive(c),
            );
          },
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

  String get _emptyTitle {
    switch (_tab) {
      case 1:
        return 'No active categories';
      case 2:
        return 'No inactive categories';
      default:
        return 'No categories yet';
    }
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