import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_users.dart';

class StudentAccountPage extends StatelessWidget {
  const StudentAccountPage({super.key});

  Future<void> _deactivate(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Deactivate account?',
      message:
      'Your account will be deactivated. You can contact support to '
          'reactivate it later.',
      confirmLabel: 'Deactivate',
      isDestructive: true,
      icon: Icons.warning_amber_rounded,
    );
    if (!confirmed || !context.mounted) return;
    AppSnackbar.showInfo(
      context,
      'Deactivate action will call the backend in Phase 2.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = MockUsers.studentProfile1;
    final user = MockUsers.student1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account Details')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _section('Account'),
            _row('Full name', profile.fullName),
            _row('Email', profile.email),
            _row('Role', user.role.label),
            _row('Status', user.status.label),
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
        ),
      ),
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
      child: Row(
        children: [
          Expanded(
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
          ),
        ],
      ),
    );
  }
}