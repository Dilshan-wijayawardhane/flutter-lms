import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../mock_data/mock_users.dart';
import '../../../../mock_data/models/mock_user.dart';
import '../widgets/user_card.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  UserRole? _roleFilter;
  UserStatus? _statusFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MockUser> get _filtered {
    return MockUsers.all.where((u) {
      final matchesQuery = _query.isEmpty ||
          u.fullName.toLowerCase().contains(_query.toLowerCase()) ||
          u.email.toLowerCase().contains(_query.toLowerCase());
      final matchesRole = _roleFilter == null || u.role == _roleFilter;
      final matchesStatus =
          _statusFilter == null || u.status == _statusFilter;
      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _roleFilter != null || _statusFilter != null;

  void _clearFilters() {
    setState(() {
      _roleFilter = null;
      _statusFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Users'),
        automaticallyImplyLeading: false,
        actions: [
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
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
                onChanged: (v) => setState(() => _query = v),
                onFilterTap: () async {
                  final result = await Navigator.of(context).pushNamed(
                    AppRoutes.adminUserFilter,
                    arguments: _AdminUserFilterArgs(
                      role: _roleFilter,
                      status: _statusFilter,
                    ),
                  );
                  if (result is _AdminUserFilterArgs) {
                    setState(() {
                      _roleFilter = result.role;
                      _statusFilter = result.status;
                    });
                  }
                },
              ),
            ),
            if (_hasActiveFilters) _filterChips(),
            Expanded(
              child: list.isEmpty
                  ? const AppEmptyState(
                icon: Icons.people_alt_outlined,
                title: 'No users found',
                message:
                'Try a different search or clear your filters.',
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final u = list[i];
                  return UserCard(
                    user: u,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.adminUserDetails,
                      arguments: u.id,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (_roleFilter != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _filterChip(
                label: _roleFilter!.label,
                onRemove: () => setState(() => _roleFilter = null),
              ),
            ),
          if (_statusFilter != null)
            _filterChip(
              label: _statusFilter!.label,
              onRemove: () => setState(() => _statusFilter = null),
            ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
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

/// Payload passed to and returned from the filter page.
class _AdminUserFilterArgs {
  const _AdminUserFilterArgs({this.role, this.status});

  final UserRole? role;
  final UserStatus? status;
}