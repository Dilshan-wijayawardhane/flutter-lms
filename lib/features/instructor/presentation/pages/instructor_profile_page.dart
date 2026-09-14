import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../mock_data/mock_users.dart';

class InstructorProfilePage extends StatelessWidget {
  const InstructorProfilePage({super.key});

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
    final profile = MockUsers.instructorProfile1;

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
            _headerCard(profile),
            const SizedBox(height: AppSpacing.lg),

            _statsCard(profile),
            const SizedBox(height: AppSpacing.lg),

            _group('Account', [
              _item(
                context,
                icon: Icons.person_outline_rounded,
                label: 'Edit profile',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.instructorEditProfile),
              ),
              _item(
                context,
                icon: Icons.badge_outlined,
                label: 'Account details',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.instructorAccount),
              ),
              _item(
                context,
                icon: Icons.lock_outline_rounded,
                label: 'Change password',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.instructorChangePassword),
              ),
            ]),
            const SizedBox(height: AppSpacing.md),

            _group('Teaching', [
              _item(
                context,
                icon: Icons.rate_review_outlined,
                label: 'My course reviews',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.instructorReviews),
              ),
              _item(
                context,
                icon: Icons.people_alt_outlined,
                label: 'Learners',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.instructorEnrollments),
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

  Widget _headerCard(dynamic profile) {
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
            name: profile.fullName,
            imageUrl: profile.profileImageUrl,
            size: 64,
            borderWidth: 2,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.fullName,
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                if (profile.headline != null)
                  Text(
                    profile.headline!,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    'INSTRUCTOR',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _stat('Courses', '${profile.totalCourses}'),
          _stat('Learners', '${profile.totalLearners}'),
          _stat('Rating', profile.averageRating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headingSmall),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
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