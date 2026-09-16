import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../providers/admin_user_provider.dart';

class AdminUserDetailsPage extends StatelessWidget {
  const AdminUserDetailsPage({super.key, required this.userId});

  final String userId;

  Future<void> _suspend(BuildContext context, AdminUserProvider p) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Suspend user?',
      message:
      'The user will be suspended and unable to log in until reactivated.',
      confirmLabel: 'Suspend',
      isDestructive: true,
      icon: Icons.block_outlined,
    );
    if (!confirmed || !context.mounted) return;
    final ok = await p.suspend(userId);
    if (!context.mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'User suspended.');
    } else {
      AppSnackbar.showError(context, p.errorMessage ?? 'Failed.');
    }
  }

  Future<void> _reactivate(BuildContext context, AdminUserProvider p) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Reactivate user?',
      message: 'The user will regain access to their account.',
      confirmLabel: 'Reactivate',
      icon: Icons.check_circle_outline_rounded,
    );
    if (!confirmed || !context.mounted) return;
    final ok = await p.reactivate(userId);
    if (!context.mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'User reactivated.');
    } else {
      AppSnackbar.showError(context, p.errorMessage ?? 'Failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminUserProvider>();
    final user = p.byId(userId);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const AppEmptyState(
          icon: Icons.person_off_outlined,
          title: 'User not found',
          message: 'This user is not available in the current list.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('User Details')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _header(user),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle('Account'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('Full name', user.fullName),
              _infoRow('Email', user.email),
              _infoRow('Role', user.role),
              _infoRow('Status', user.status),
              if (user.createdAt != null)
                _infoRow('Joined', Formatters.date(user.createdAt)),
            ]),
            const SizedBox(height: AppSpacing.xl),
            if (user.status == 'ACTIVE' || user.status == 'active')
              AppButton.danger(
                label: 'Suspend User',
                icon: Icons.block_outlined,
                onPressed: () => _suspend(context, p),
              )
            else
              AppButton.primary(
                label: 'Reactivate User',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () => _reactivate(context, p),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(
            name: user.fullName,
            imageUrl: user.profileImageUrl,
            size: 56,
            borderWidth: 2,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName,
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Text(user.email, style: AppTextStyles.caption),
                const SizedBox(height: 6),
                _statusChip(user.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final upper = status.toUpperCase();
    switch (upper) {
      case 'ACTIVE':
        return const AppStatusChip(status: AppStatus.active);
      case 'INACTIVE':
        return const AppStatusChip(status: AppStatus.inactive);
      case 'SUSPENDED':
        return const AppStatusChip(status: AppStatus.suspended);
      default:
        return const AppStatusChip(status: AppStatus.inactive);
    }
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: AppTextStyles.headingSmall);

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.labelLarge,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}