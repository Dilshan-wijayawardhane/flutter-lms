import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../student/providers/instructor_course_provider.dart';

class InstructorEditSectionPage extends StatefulWidget {
  const InstructorEditSectionPage({
    super.key,
    required this.courseId,
    required this.sectionId,
  });

  final String courseId;
  final String sectionId;

  @override
  State<InstructorEditSectionPage> createState() =>
      _InstructorEditSectionPageState();
}

class _InstructorEditSectionPageState
    extends State<InstructorEditSectionPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final sections =
    context.read<InstructorCourseProvider>().sectionsFor(widget.courseId);
    final s = sections.firstWhere(
          (x) => x.id == widget.sectionId,
      orElse: () => throw StateError('Section not found'),
    );
    _titleCtrl = TextEditingController(text: s.title);
    _descCtrl = TextEditingController(text: s.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<InstructorCourseProvider>();
    final ok = await p.updateSection(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      AppSnackbar.showSuccess(context, 'Section updated.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        p.errorMessage ?? 'Could not update section.',
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete section?',
      message: 'All lessons will be removed. This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    final p = context.read<InstructorCourseProvider>();
    final ok = await p.deleteSection(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Section deleted.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        p.errorMessage ?? 'Could not delete section.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Section'),
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
              AppTextField(
                controller: _titleCtrl,
                label: 'Section title',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Section title'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'Description',
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}