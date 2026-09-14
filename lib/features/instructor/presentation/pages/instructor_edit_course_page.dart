import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../../../mock_data/mock_categories.dart';
import '../../../../mock_data/mock_courses.dart';
import '../../../../mock_data/models/mock_category.dart';
import '../../../../mock_data/models/mock_course.dart';

class InstructorEditCoursePage extends StatefulWidget {
  const InstructorEditCoursePage({super.key, required this.courseId});

  final String courseId;

  @override
  State<InstructorEditCoursePage> createState() =>
      _InstructorEditCoursePageState();
}

class _InstructorEditCoursePageState
    extends State<InstructorEditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _shortCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  MockCourse? _course;
  MockCategory? _category;
  CourseLevel _level = CourseLevel.beginner;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _course = _find(widget.courseId);
    final c = _course;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _shortCtrl = TextEditingController(text: c?.shortDescription ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _priceCtrl = TextEditingController(
      text: (c?.price ?? 0).toStringAsFixed(2),
    );
    _level = c?.level ?? CourseLevel.beginner;
    for (final cat in MockCategories.all) {
      if (cat.id == c?.categoryId) {
        _category = cat;
        break;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _shortCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  MockCourse? _find(String id) {
    for (final c in MockCourses.all) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSaving = false);
    AppSnackbar.showSuccess(context, 'Course updated (mock).');
    Navigator.of(context).pop();
  }

  Future<void> _archive() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Archive course?',
      message:
      'The course will be hidden from students. You can restore it later.',
      confirmLabel: 'Archive',
      isDestructive: true,
      icon: Icons.archive_outlined,
    );
    if (!confirmed || !mounted) return;
    AppSnackbar.showInfo(context, 'Archive will call the backend in Phase 2.');
  }

  @override
  Widget build(BuildContext context) {
    final c = _course;
    if (c == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Course not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archive',
            onPressed: _archive,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _statusRow(c),
              const SizedBox(height: AppSpacing.md),
              ImagePickerField(
                imageUrl: c.thumbnailUrl,
                label: 'Course thumbnail',
                height: 180,
                onPickRequested: () => AppSnackbar.showInfo(
                  context,
                  'Thumbnail picker arrives with backend integration.',
                ),
                onRemove: () => AppSnackbar.showInfo(
                  context,
                  'Remove thumbnail will call the backend in Phase 2.',
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
                validator: (v) =>
                    Validators.minLength(v, 8, field: 'Short description'),
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

              AppDropdown<MockCategory>(
                label: 'Category',
                items: MockCategories.active,
                value: _category,
                labelBuilder: (c) => c.name,
                onChanged: (c) => setState(() => _category = c),
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
                label: 'Price',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppButton.primary(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusRow(MockCourse c) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text('Status', style: AppTextStyles.labelMedium),
          const Spacer(),
          switch (c.status) {
            CourseStatus.draft =>
            const AppStatusChip(status: AppStatus.draft),
            CourseStatus.published =>
            const AppStatusChip(status: AppStatus.published),
            CourseStatus.archived =>
            const AppStatusChip(status: AppStatus.archived),
          },
        ],
      ),
    );
  }
}