import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../../../mock_data/mock_users.dart';

class StudentEditProfilePage extends StatefulWidget {
  const StudentEditProfilePage({super.key});

  @override
  State<StudentEditProfilePage> createState() =>
      _StudentEditProfilePageState();
}

class _StudentEditProfilePageState extends State<StudentEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _interestsCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = MockUsers.studentProfile1;
    _nameCtrl = TextEditingController(text: p.fullName);
    _phoneCtrl = TextEditingController(text: p.phone ?? '');
    _countryCtrl = TextEditingController(text: p.country ?? '');
    _educationCtrl = TextEditingController(text: p.educationLevel ?? '');
    _bioCtrl = TextEditingController(text: p.bio ?? '');
    _interestsCtrl = TextEditingController(text: p.interests.join(', '));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _educationCtrl.dispose();
    _bioCtrl.dispose();
    _interestsCtrl.dispose();
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
                controller: _phoneCtrl,
                label: 'Phone',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _countryCtrl,
                label: 'Country',
                prefixIcon: Icons.public_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _educationCtrl,
                label: 'Education level',
                prefixIcon: Icons.school_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _interestsCtrl,
                label: 'Interests (comma separated)',
                prefixIcon: Icons.star_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _bioCtrl,
                label: 'Bio',
                maxLines: 4,
                validator: (v) =>
                    Validators.maxLength(v, 500, field: 'Bio'),
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