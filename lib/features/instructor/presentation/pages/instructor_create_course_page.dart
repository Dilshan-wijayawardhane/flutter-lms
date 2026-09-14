import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../../../mock_data/mock_categories.dart';
import '../../../../mock_data/models/mock_category.dart';
import '../../../../mock_data/models/mock_course.dart';

class InstructorCreateCoursePage extends StatefulWidget {
  const InstructorCreateCoursePage({super.key});

  @override
  State<InstructorCreateCoursePage> createState() =>
      _InstructorCreateCoursePageState();
}

class _InstructorCreateCoursePageState
    extends State<InstructorCreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _shortCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');

  MockCategory? _category;
  CourseLevel _level = CourseLevel.beginner;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _shortCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      AppSnackbar.showError(context, 'Please select a category.');
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSaving = false);
    AppSnackbar.showSuccess(
      context,
      publish
          ? 'Course published (mock).'
          : 'Course saved as draft (mock).',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Course')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ImagePickerField(
                label: 'Course thumbnail',
                height: 180,
                onPickRequested: () => AppSnackbar.showInfo(
                  context,
                  'Thumbnail picker arrives with backend integration.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: _titleCtrl,
                label: 'Course title',
                hint: 'e.g., Flutter Fundamentals',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 5, field: 'Course title'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _shortCtrl,
                label: 'Short description',
                hint: 'One-line summary shown on course cards',
                prefixIcon: Icons.short_text_rounded,
                maxLines: 2,
                validator: (v) =>
                    Validators.minLength(v, 8, field: 'Short description'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _descCtrl,
                label: 'Full description',
                hint:
                'Describe what students will learn and any prerequisites.',
                maxLines: 6,
                minLines: 4,
                validator: (v) =>
                    Validators.minLength(v, 30, field: 'Description'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppDropdown<MockCategory>(
                label: 'Category',
                hint: 'Select a category',
                items: MockCategories.active,
                value: _category,
                labelBuilder: (c) => c.name,
                onChanged: (c) => setState(() => _category = c),
                validator: (v) =>
                v == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppDropdown<CourseLevel>(
                label: 'Level',
                items: CourseLevel.values,
                value: _level,
                labelBuilder: (l) => l.label,
                onChanged: (l) =>
                    setState(() => _level = l ?? CourseLevel.beginner),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _priceCtrl,
                label: 'Price (0 for free)',
                hint: '0',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              AppButton.primary(
                label: 'Save as Draft',
                icon: Icons.save_outlined,
                isLoading: _isSaving,
                onPressed: () => _save(publish: false),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Publish Course',
                icon: Icons.publish_rounded,
                onPressed: _isSaving ? null : () => _save(publish: true),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'In the backend integration phase, publishing will require '
                    'at least one section and one lesson.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}