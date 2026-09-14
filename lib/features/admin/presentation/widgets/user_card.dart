import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../mock_data/models/mock_user.dart';

/// User row used on the admin users list.
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  final MockUser user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              AppAvatar(
                name: user.fullName,
                imageUrl: user.profileImageUrl,
                size: 44,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _roleChip(user.role),
                        const SizedBox(width: AppSpacing.xs),
                        _statusChip(user.status),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleChip(UserRole role) {
    final color = switch (role) {
      UserRole.student => AppColors.info,
      UserRole.instructor => AppColors.primary,
      UserRole.admin => AppColors.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        role.label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _statusChip(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return const AppStatusChip(status: AppStatus.active, dense: true);
      case UserStatus.inactive:
        return const AppStatusChip(
          status: AppStatus.inactive,
          dense: true,
        );
      case UserStatus.suspended:
        return const AppStatusChip(
          status: AppStatus.suspended,
          dense: true,
        );
    }
  }
}