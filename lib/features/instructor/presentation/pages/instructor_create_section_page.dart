import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../student/providers/instructor_course_provider.dart';

class InstructorCreateSectionPage extends StatefulWidget {
  const InstructorCreateSectionPage({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<InstructorCreateSectionPage> createState() =>
      _InstructorCreateSectionPageState();
}

class _InstructorCreateSectionPageState
    extends State<InstructorCreateSectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

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
    final s = await p.createSection(
      courseId: widget.courseId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (s != null) {
      AppSnackbar.showSuccess(context, 'Section created.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        p.errorMessage ?? 'Could not create section.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Section')),
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
                hint: 'e.g., Getting Started',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Section title'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'Description (optional)',
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Create Section',
                icon: Icons.check_rounded,
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