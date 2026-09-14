import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../mock_data/models/mock_user.dart';

/// Public payload type used to pass filter values to and from
/// [AdminUserFilterPage].
class AdminUserFilterArgs {
  const AdminUserFilterArgs({this.role, this.status});

  final UserRole? role;
  final UserStatus? status;
}

class AdminUserFilterPage extends StatefulWidget {
  const AdminUserFilterPage({super.key, this.initial});

  final AdminUserFilterArgs? initial;

  @override
  State<AdminUserFilterPage> createState() => _AdminUserFilterPageState();
}

class _AdminUserFilterPageState extends State<AdminUserFilterPage> {
  UserRole? _role;
  UserStatus? _status;

  @override
  void initState() {
    super.initState();
    _role = widget.initial?.role;
    _status = widget.initial?.status;
  }

  void _apply() {
    Navigator.of(context).pop(
      AdminUserFilterArgs(role: _role, status: _status),
    );
  }

  void _reset() {
    setState(() {
      _role = null;
      _status = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Filter Users'),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('Role', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            ...UserRole.values.map(
                  (r) => _option(
                label: r.label,
                selected: _role == r,
                onTap: () => setState(
                      () => _role = _role == r ? null : r,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Status', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            ...UserStatus.values.map(
                  (s) => _option(
                label: s.label,
                selected: _status == s,
                onTap: () => setState(
                      () => _status = _status == s ? null : s,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: 'Apply Filters',
              icon: Icons.check_rounded,
              onPressed: _apply,
            ),
          ],
        ),
      ),
    );
  }

  Widget _option({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySurface
                : AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}