import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Generic dropdown field with consistent styling.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
    this.label,
    this.hint = 'Select',
    this.validator,
    this.enabled = true,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) labelBuilder;
  final String? label;
  final String hint;
  final String? Function(T?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.labelMedium),
          const SizedBox(height: AppSpacing.xs),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          validator: validator,
          onChanged: enabled ? onChanged : null,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}