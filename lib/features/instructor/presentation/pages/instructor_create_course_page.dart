import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../student/data/models/category.dart';
import '../../../student/data/models/course.dart';
import '../../../student/providers/category_provider.dart';
import '../../providers/instructor_course_provider.dart';

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

  CourseCategory? _category;
  CourseLevel _level = CourseLevel.beginner;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().load();
    });
  }

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
    final provider = context.read<InstructorCourseProvider>();
    final created = await provider.createCourse(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      shortDescription: _shortCtrl.text.trim(),
      categoryId: _category!.id,
      level: _level,
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      publish: publish,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (created != null) {
      AppSnackbar.showSuccess(
        context,
        publish ? 'Course published.' : 'Course saved as draft.',
      );
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        provider.errorMessage ?? 'Could not create course.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>();

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
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Save the course first, then add a thumbnail from the Edit screen.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _titleCtrl,
                label: 'Course title',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 5, field: 'Course title'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _shortCtrl,
                label: 'Short description',
                maxLines: 2,
                validator: (v) => Validators.minLength(v, 8,
                    field: 'Short description'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'Full description',
                maxLines: 6,
                minLines: 4,
                validator: (v) =>
                    Validators.minLength(v, 30, field: 'Description'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppDropdown<CourseCategory>(
                label: 'Category',
                items: categories.categories,
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
                labelBuilder: (l) => l.name.toUpperCase(),
                onChanged: (l) =>
                    setState(() => _level = l ?? CourseLevel.beginner),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _priceCtrl,
                label: 'Price (0 for free)',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save as Draft',
                icon: Icons.save_outlined,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : () => _save(publish: false),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Publish Course',
                icon: Icons.publish_rounded,
                onPressed: _isSaving ? null : () => _save(publish: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}