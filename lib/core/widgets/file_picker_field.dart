import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// UI-only file picker field.
///
/// Does NOT use file_picker yet. Shows the currently selected file (if any)
/// and calls [onPickRequested] when tapped.
class FilePickerField extends StatelessWidget {
  const FilePickerField({
    super.key,
    this.fileName,
    this.fileSizeLabel,
    this.onPickRequested,
    this.onRemove,
    this.title = 'Attach file',
    this.allowedTypesLabel = 'PDF, DOCX, ZIP up to 20MB',
    this.icon = Icons.upload_file_rounded,
  });

  final String? fileName;
  final String? fileSizeLabel;
  final VoidCallback? onPickRequested;
  final VoidCallback? onRemove;
  final String title;
  final String allowedTypesLabel;
  final IconData icon;

  bool get _hasFile => fileName != null && fileName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickRequested,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: _hasFile ? _fileContent() : _emptyContent(),
      ),
    );
  }

  Widget _emptyContent() => Row(
    children: [
      Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.labelLarge),
            const SizedBox(height: 2),
            Text(allowedTypesLabel, style: AppTextStyles.caption),
          ],
        ),
      ),
      const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.textTertiary,
      ),
    ],
  );

  Widget _fileContent() => Row(
    children: [
      Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: const Icon(
          Icons.insert_drive_file_outlined,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName!,
              style: AppTextStyles.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (fileSizeLabel != null)
              Text(fileSizeLabel!, style: AppTextStyles.caption),
          ],
        ),
      ),
      if (onRemove != null)
        IconButton(
          onPressed: onRemove,
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.danger,
          ),
        ),
    ],
  );
}