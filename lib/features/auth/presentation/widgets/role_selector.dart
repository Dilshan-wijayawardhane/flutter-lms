import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/mock_role.dart';

/// Segmented role picker used on the Login screen.
class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MockRole selected;
  final ValueChanged<MockRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MockRole.values.map((role) {
        final isSelected = role == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: role == MockRole.values.last ? 0 : AppSpacing.xs,
            ),
            child: GestureDetector(
              onTap: () => onChanged(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _iconFor(role),
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.label,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(MockRole role) {
    switch (role) {
      case MockRole.student:
        return Icons.person_outline_rounded;
      case MockRole.instructor:
        return Icons.co_present_outlined;
      case MockRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}