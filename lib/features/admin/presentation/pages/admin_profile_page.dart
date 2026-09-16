import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../student/providers/profile_provider.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProfileProvider>();
      if (!p.hasProfile && !p.isLoading) p.load();
    });
  }

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
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.read<ProfileProvider>().clear();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: provider.isLoading
                ? null
                : () => provider.load(force: true),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: provider.isLoading && !provider.hasProfile
            ? const AppLoading(message: 'Loading profile…')
            : provider.hasError && !provider.hasProfile
            ? AppErrorState(
          title: 'Could not load profile',
          message: provider.errorMessage ?? 'Please try again.',
          onRetry: () => provider.load(force: true),
        )
            : provider.profile == null
            ? const AppEmptyState(
          icon: Icons.person_outline_rounded,
          title: 'No profile',
          message: 'Your profile is not available.',
        )
            : _body(provider),
      ),
    );
  }

  Widget _body(ProfileProvider provider) {
    final p = provider.profile!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _header(p),
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
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.adminUsers),
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
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.adminCourses),
          ),
          _item(
            context,
            icon: Icons.rate_review_outlined,
            label: 'Review moderation',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.adminReviews),
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
            'Version 0.7.0 · Phase 7',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }

  Widget _header(profile) {
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
                Text(
                  profile.fullName,
                  style: AppTextStyles.headingSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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