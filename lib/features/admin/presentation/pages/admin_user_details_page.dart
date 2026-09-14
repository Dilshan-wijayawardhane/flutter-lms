import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_users.dart';
import '../../../../mock_data/models/mock_user.dart';

class AdminUserDetailsPage extends StatefulWidget {
  const AdminUserDetailsPage({super.key, required this.userId});

  final String userId;

  @override
  State<AdminUserDetailsPage> createState() => _AdminUserDetailsPageState();
}

class _AdminUserDetailsPageState extends State<AdminUserDetailsPage> {
  late MockUser? _user;

  @override
  void initState() {
    super.initState();
    _user = _find();
  }

  MockUser? _find() {
    for (final u in MockUsers.all) {
      if (u.id == widget.userId) return u;
    }
    return null;
  }

  Future<void> _suspend() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Suspend user?',
      message:
      '${_user!.fullName} will be suspended and unable to log in until '
          'reactivated.',
      confirmLabel: 'Suspend',
      isDestructive: true,
      icon: Icons.block_outlined,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _user = _user!.copyWith(status: UserStatus.suspended);
    });
    AppSnackbar.showSuccess(context, 'User suspended (mock).');
  }

  Future<void> _reactivate() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Reactivate user?',
      message:
      '${_user!.fullName} will regain access to their account.',
      confirmLabel: 'Reactivate',
      icon: Icons.check_circle_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _user = _user!.copyWith(status: UserStatus.active);
    });
    AppSnackbar.showSuccess(context, 'User reactivated (mock).');
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('User not found')),
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
              _infoRow('Role', user.role.label),
              _infoRow('Status', user.status.label),
              if (user.createdAt != null)
                _infoRow('Joined', Formatters.date(user.createdAt)),
            ]),
            const SizedBox(height: AppSpacing.lg),

            _sectionTitle('Identifier'),
            const SizedBox(height: AppSpacing.xs),
            _infoCard([
              _infoRow('User ID', user.id),
            ]),
            const SizedBox(height: AppSpacing.xl),

            if (user.status == UserStatus.active)
              AppButton.danger(
                label: 'Suspend User',
                icon: Icons.block_outlined,
                onPressed: _suspend,
              )
            else if (user.status == UserStatus.suspended)
              AppButton.primary(
                label: 'Reactivate User',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _reactivate,
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(MockUser user) {
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

  Widget _statusChip(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return const AppStatusChip(status: AppStatus.active);
      case UserStatus.inactive:
        return const AppStatusChip(status: AppStatus.inactive);
      case UserStatus.suspended:
        return const AppStatusChip(status: AppStatus.suspended);
    }
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: AppTextStyles.headingSmall);

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
      crossAxisAlignment: CrossAxisAlignment.start,
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