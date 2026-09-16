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
import '../../../../core/widgets/app_search_bar.dart';
import '../../providers/admin_user_provider.dart';
import '../widgets/user_card.dart';
import 'admin_user_filter_page.dart' show AdminUserFilterArgs;

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminUserProvider>();
      if (p.state != LoadState.success) p.load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminUserProvider>();
    final hasFilters =
        p.roleFilter != null || p.statusFilter != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Users'),
        automaticallyImplyLeading: false,
        actions: [
          if (hasFilters)
            TextButton(
              onPressed: p.clearFilters,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Search by name or email',
                onChanged: (v) => p.setSearch(v),
                onFilterTap: () async {
                  final result = await Navigator.of(context).pushNamed(
                    AppRoutes.adminUserFilter,
                    arguments: AdminUserFilterArgs(
                      role: p.roleFilter,
                      status: p.statusFilter,
                    ),
                  );
                  if (result is AdminUserFilterArgs) {
                    await p.setFilters(
                      role: result.role,
                      status: result.status,
                    );
                  }
                },
              ),
            ),
            if (hasFilters) _filterChips(p),
            Expanded(child: _body(p)),
          ],
        ),
      ),
    );
  }

  Widget _body(AdminUserProvider p) {
    if (p.state == LoadState.loading && p.users.isEmpty) {
      return const AppLoading(message: 'Loading users…');
    }
    if (p.state == LoadState.error && p.users.isEmpty) {
      return AppErrorState(
        title: 'Could not load users',
        message: p.errorMessage ?? 'Please try again.',
        onRetry: () => p.load(force: true),
      );
    }
    if (p.users.isEmpty) {
      return const AppEmptyState(
        icon: Icons.people_alt_outlined,
        title: 'No users found',
        message: 'Try a different search or clear your filters.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => p.load(force: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        itemCount: p.users.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final u = p.users[i];
          return UserCard(
            user: u,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.adminUserDetails,
              arguments: u.id,
            ),
          );
        },
      ),
    );
  }

  Widget _filterChips(AdminUserProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          if (p.roleFilter != null)
            _chip(
              p.roleFilter!,
                  () => p.setFilters(status: p.statusFilter),
            ),
          if (p.statusFilter != null)
            _chip(
              p.statusFilter!,
                  () => p.setFilters(role: p.roleFilter),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}