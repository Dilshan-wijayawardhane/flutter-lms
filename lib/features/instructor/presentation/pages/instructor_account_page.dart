import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../student/providers/profile_provider.dart';

class InstructorAccountPage extends StatelessWidget {
  const InstructorAccountPage({super.key});

  Future<void> _deactivate(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Deactivate account?',
      message:
      'Your account will be deactivated and your courses will be hidden from students.',
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
        _row('Full name', p.fullName),
        _row('Email', p.email),
        _row('Role', p.role),
        _row('Status', p.status),
        const SizedBox(height: AppSpacing.lg),
        _section('Professional'),
        _row('Headline', p.headline ?? '—'),
        _row('Qualification', p.qualification ?? '—'),
        _row(
          'Experience',
          p.experienceYears != null ? '${p.experienceYears} years' : '—',
        ),
        _row(
          'Expertise',
          p.expertise.isEmpty ? '—' : p.expertise.join(', '),
        ),
        const SizedBox(height: AppSpacing.lg),
        _section('Security'),
        _row('Password', '••••••••',
            trailing: 'Change in Change Password screen'),
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

  Widget _row(String label, String value, {String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.labelLarge),
          if (trailing != null) ...[
            const SizedBox(height: 2),
            Text(trailing, style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}