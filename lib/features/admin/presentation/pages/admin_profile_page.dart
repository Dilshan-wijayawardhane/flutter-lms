import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../mock_data/mock_users.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Log out?',
      message: 'You will be returned to the login screen.',
      confirmLabel: 'Log out',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = MockUsers.admin1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _header(user),
            const SizedBox(height: AppSpacing.lg),
            _group('Account', [
              _item(
                context,
                icon: Icons.badge_outlined,
                label: 'Account details',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminAccount),
              ),
              _item(
                context,
                icon: Icons.lock_outline_rounded,
                label: 'Change password',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminChangePassword),
              ),
            ]),
            const SizedBox(height: AppSpacing.md),
            _group('Platform', [
              _item(
                context,
                icon: Icons.people_alt_outlined,
                label: 'Manage users',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminUsers),
              ),
              _item(
                context,
                icon: Icons.category_outlined,
                label: 'Manage categories',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminCategories),
              ),
              _item(
                context,
                icon: Icons.menu_book_outlined,
                label: 'All courses',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminCourses),
              ),
              _item(
                context,
                icon: Icons.rate_review_outlined,
                label: 'Review moderation',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.adminReviews),
              ),
            ]),
            const SizedBox(height: AppSpacing.md),
            _group('Danger zone', [
              _item(
                context,
                icon: Icons.logout_rounded,
                label: 'Log out',
                color: AppColors.danger,
                onTap: () => _logout(context),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Version 0.1.0 · Phase 1 (UI only)',
                style: AppTextStyles.caption,
              ),
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
            size: 64,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    'ADMIN',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Text(title, style: AppTextStyles.labelMedium),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _item(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        Color? color,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color ?? AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}