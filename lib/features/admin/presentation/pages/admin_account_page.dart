import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/providers/profile_provider.dart';

class AdminAccountPage extends StatelessWidget {
  const AdminAccountPage({super.key});

  Future<void> _deactivate(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Deactivate account?',
      message:
      'Your admin account will be deactivated. Contact platform support '
          'to reactivate it.',
      confirmLabel: 'Deactivate',
      isDestructive: true,
      icon: Icons.warning_amber_rounded,
    );
    if (!confirmed || !context.mounted) return;
    AppSnackbar.showInfo(
      context,
      'Deactivate action will call the backend in a later phase.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account Details')),
      body: SafeArea(
        top: false,
        child: provider.isLoading && !provider.hasProfile
            ? const AppLoading(message: 'Loading account…')
            : provider.profile == null
            ? const AppEmptyState(
          icon: Icons.badge_outlined,
          title: 'No account data',
          message: 'Your account details are not available yet.',
        )
            : _body(context, provider),
      ),
    );
  }

  Widget _body(BuildContext context, ProfileProvider provider) {
    final p = provider.profile!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _section('Account'),
        _infoCard([
          _infoRow('Full name', p.fullName),
          _infoRow('Email', p.email),
          _infoRow('Role', p.role),
          _infoRow('Status', p.status),
          _infoRow('Email verified', p.isEmailVerified ? 'Yes' : 'No'),
          _infoRow('User ID', p.id),
        ]),
        if (p.createdAt != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _section('Membership'),
          _infoCard([
            _infoRow('Joined', Formatters.date(p.createdAt)),
          ]),
        ],
        const SizedBox(height: AppSpacing.lg),
        _section('Security'),
        _infoCard([
          _infoRow(
            'Password',
            '••••••••',
          ),
          _infoRow(
            'Change password',
            'Use the Change Password screen',
          ),
        ]),
        const SizedBox(height: AppSpacing.xl),
        AppButton.danger(
          label: 'Deactivate Account',
          icon: Icons.warning_amber_rounded,
          onPressed: () => _deactivate(context),
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Text(title, style: AppTextStyles.headingSmall),
  );

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