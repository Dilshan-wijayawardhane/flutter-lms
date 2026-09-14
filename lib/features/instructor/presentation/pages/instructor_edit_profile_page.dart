import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../../../mock_data/mock_users.dart';

class InstructorEditProfilePage extends StatefulWidget {
  const InstructorEditProfilePage({super.key});

  @override
  State<InstructorEditProfilePage> createState() =>
      _InstructorEditProfilePageState();
}

class _InstructorEditProfilePageState
    extends State<InstructorEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _headlineCtrl;
  late final TextEditingController _qualificationCtrl;
  late final TextEditingController _experienceCtrl;
  late final TextEditingController _expertiseCtrl;
  late final TextEditingController _bioCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = MockUsers.instructorProfile1;
    _nameCtrl = TextEditingController(text: p.fullName);
    _headlineCtrl = TextEditingController(text: p.headline ?? '');
    _qualificationCtrl =
        TextEditingController(text: p.qualification ?? '');
    _experienceCtrl =
        TextEditingController(text: '${p.experienceYears}');
    _expertiseCtrl = TextEditingController(text: p.expertise.join(', '));
    _bioCtrl = TextEditingController(text: p.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _headlineCtrl.dispose();
    _qualificationCtrl.dispose();
    _experienceCtrl.dispose();
    _expertiseCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Profile saved (mock).');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ImagePickerField(
                label: 'Change profile picture',
                onPickRequested: () => AppSnackbar.showInfo(
                  context,
                  'Image picker arrives with backend integration.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: _nameCtrl,
                label: 'Full name',
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                    Validators.minLength(v, 2, field: 'Full name'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _headlineCtrl,
                label: 'Headline',
                prefixIcon: Icons.badge_outlined,
                validator: (v) =>
                    Validators.minLength(v, 4, field: 'Headline'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _qualificationCtrl,
                label: 'Qualification',
                prefixIcon: Icons.school_outlined,
                validator: (v) =>
                    Validators.minLength(v, 2, field: 'Qualification'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _experienceCtrl,
                label: 'Years of experience',
                prefixIcon: Icons.timelapse_rounded,
                keyboardType: TextInputType.number,
                validator: Validators.experience,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _expertiseCtrl,
                label: 'Expertise (comma separated)',
                prefixIcon: Icons.star_outline_rounded,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Expertise'),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _bioCtrl,
                label: 'Bio',
                maxLines: 6,
                minLines: 4,
                validator: (v) =>
                    Validators.minLength(v, 20, field: 'Bio'),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppButton.primary(
                label: 'Save Changes',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}