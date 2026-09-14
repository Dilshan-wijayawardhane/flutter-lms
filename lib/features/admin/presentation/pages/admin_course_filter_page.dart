import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../mock_data/mock_categories.dart';
import '../../../../mock_data/models/mock_course.dart';
import 'admin_courses_page.dart' show AdminCourseFilterArgs;

class AdminCourseFilterPage extends StatefulWidget {
  const AdminCourseFilterPage({super.key, this.initial});

  final AdminCourseFilterArgs? initial;

  @override
  State<AdminCourseFilterPage> createState() =>
      _AdminCourseFilterPageState();
}

class _AdminCourseFilterPageState extends State<AdminCourseFilterPage> {
  CourseStatus? _status;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _status = widget.initial?.status;
    _categoryId = widget.initial?.categoryId;
  }

  void _apply() {
    Navigator.of(context).pop(
      AdminCourseFilterArgs(
        status: _status,
        categoryId: _categoryId,
      ),
    );
  }

  void _reset() {
    setState(() {
      _status = null;
      _categoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Filter Courses'),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('Status', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            ...CourseStatus.values.map(
                  (s) => _option(
                label: s.label,
                selected: _status == s,
                onTap: () => setState(
                      () => _status = _status == s ? null : s,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Category', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            ...MockCategories.all.map(
                  (c) => _option(
                label: c.name,
                selected: _categoryId == c.id,
                onTap: () => setState(
                      () => _categoryId = _categoryId == c.id ? null : c.id,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: 'Apply Filters',
              icon: Icons.check_rounded,
              onPressed: _apply,
            ),
          ],
        ),
      ),
    );
  }

  Widget _option({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySurface
                : AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}