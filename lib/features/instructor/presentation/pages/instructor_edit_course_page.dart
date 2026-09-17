import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/media_picker.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../../student/data/models/category.dart';
import '../../../student/data/models/course.dart';
import '../../../student/providers/category_provider.dart';
import '../../providers/instructor_course_provider.dart';

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

  CourseCategory? _category;
  CourseLevel _level = CourseLevel.beginner;
  bool _isSaving = false;

  PickedMedia? _pickedImage;
  double? _uploadProgress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().load();
    });

    final course = context
        .read<InstructorCourseProvider>()
        .courseById(widget.courseId);
    _titleCtrl = TextEditingController(text: course?.title ?? '');
    _shortCtrl =
        TextEditingController(text: course?.shortDescription ?? '');
    _descCtrl = TextEditingController(text: course?.description ?? '');
    _priceCtrl = TextEditingController(
      text: (course?.price ?? 0).toStringAsFixed(2),
    );
    _level = course?.level ?? CourseLevel.beginner;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _shortCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<InstructorCourseProvider>();
    final updated = await provider.updateCourse(
      courseId: widget.courseId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      shortDescription: _shortCtrl.text.trim(),
      categoryId: _category?.id,
      level: _level,
      price: double.tryParse(_priceCtrl.text.trim()),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (updated != null) {
      AppSnackbar.showSuccess(context, 'Course updated.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        provider.errorMessage ?? 'Could not update course.',
      );
    }
  }

  Future<void> _uploadThumbnail() async {
    final picked = _pickedImage;
    if (picked == null) return;

    setState(() => _uploadProgress = 0);

    final ok = await context
        .read<InstructorCourseProvider>()
        .uploadCourseThumbnail(
      courseId: widget.courseId,
      filePath: picked.path,
      fileName: picked.name,
      mimeType: picked.mimeType,
      onSendProgress: (sent, total) {
        if (total <= 0) return;
        if (!mounted) return;
        final double ratio = sent / total;
        setState(() => _uploadProgress = ratio);
      },
    );

    if (!mounted) return;
    setState(() => _uploadProgress = null);

    if (ok != null) {
      AppSnackbar.showSuccess(context, 'Thumbnail uploaded.');
      setState(() => _pickedImage = null);
    } else {
      AppSnackbar.showError(context, 'Upload failed.');
    }
  }

  Future<void> _removeThumbnail() async {
    final ok = await context
        .read<InstructorCourseProvider>()
        .deleteCourseThumbnail(widget.courseId);
    if (!mounted) return;
    if (ok != null) {
      setState(() => _pickedImage = null);
      AppSnackbar.showSuccess(context, 'Thumbnail removed.');
    } else {
      AppSnackbar.showError(context, 'Could not remove thumbnail.');
    }
  }

  Future<void> _publish() async {
    final ok = await context
        .read<InstructorCourseProvider>()
        .publishCourse(widget.courseId);
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Course published.' : 'Could not publish.',
    );
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

    final ok = await context
        .read<InstructorCourseProvider>()
        .archiveCourse(widget.courseId);
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Course archived.' : 'Could not archive.',
    );
    if (ok) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete course?',
      message:
      'The course and all its content will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    final ok = await context
        .read<InstructorCourseProvider>()
        .deleteCourse(widget.courseId);
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      ok ? 'Course deleted.' : 'Could not delete.',
    );
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstructorCourseProvider>();
    final course = provider.courseById(widget.courseId);
    if (course == null) {
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
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger),
            tooltip: 'Delete',
            onPressed: _delete,
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
              _statusRow(course),
              const SizedBox(height: AppSpacing.md),
              ImagePickerField(
                imageUrl: course.thumbnailUrl,
                localFilePath: _pickedImage?.path,
                uploadProgress: _uploadProgress,
                label: 'Course thumbnail',
                height: 180,
                onPicked: (m) => setState(() => _pickedImage = m),
                onUpload:
                _pickedImage == null ? null : _uploadThumbnail,
                onRemove: _removeThumbnail,
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
                items: context.watch<CategoryProvider>().categories,
                value: _category,
                labelBuilder: (c) => c.name,
                onChanged: (c) => setState(() => _category = c),
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
                onPressed: _isSaving ? null : _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (course.status != CourseStatus.published)
                AppButton.secondary(
                  label: 'Publish Course',
                  icon: Icons.publish_rounded,
                  onPressed: _publish,
                )
              else
                AppButton.secondary(
                  label: 'Archive Course',
                  icon: Icons.archive_outlined,
                  onPressed: _archive,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusRow(Course c) {
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