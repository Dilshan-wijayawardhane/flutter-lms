import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/register_request.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class InstructorRegisterPage extends StatefulWidget {
  const InstructorRegisterPage({super.key});

  @override
  State<InstructorRegisterPage> createState() =>
      _InstructorRegisterPageState();
}

class _InstructorRegisterPageState extends State<InstructorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _headlineCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _expertiseCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _headlineCtrl.dispose();
    _qualificationCtrl.dispose();
    _experienceCtrl.dispose();
    _expertiseCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final expertise = _expertiseCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final ok = await auth.registerInstructor(
      InstructorRegisterRequest(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        headline: _headlineCtrl.text.trim(),
        qualification: _qualificationCtrl.text.trim(),
        experienceYears:
        int.tryParse(_experienceCtrl.text.trim()) ?? 0,
        expertise: expertise,
        bio: _bioCtrl.text.trim(),
      ),
    );

    if (!mounted) return;

    if (ok) {
      AppSnackbar.showSuccess(
        context,
        'Account created. Check your email for the verification code.',
      );
      Navigator.of(context).pushNamed(
        AppRoutes.verifyEmail,
        arguments: _emailCtrl.text.trim(),
      );
    } else {
      AppSnackbar.showError(
        context,
        auth.errorMessage ?? 'Registration failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  title: 'Create Instructor Account',
                  subtitle:
                  'Share your knowledge and grow your audience.',
                ),
                const SizedBox(height: AppSpacing.xl),

                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full name',
                  hint: 'Dr. Jane Doe',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.minLength(v, 2, field: 'Full name'),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),

                AppPasswordField(
                  controller: _passwordCtrl,
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),

                AppPasswordField(
                  controller: _confirmCtrl,
                  label: 'Confirm password',
                  hint: 'Repeat your password',
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordCtrl.text),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _headlineCtrl,
                  label: 'Headline',
                  hint: 'Senior Flutter Engineer & Educator',
                  prefixIcon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.minLength(v, 4, field: 'Headline'),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _qualificationCtrl,
                  label: 'Qualification',
                  hint: 'MSc in Computer Science',
                  prefixIcon: Icons.school_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.minLength(v, 2, field: 'Qualification'),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _experienceCtrl,
                  label: 'Years of experience',
                  hint: '5',
                  prefixIcon: Icons.timelapse_rounded,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: Validators.experience,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _expertiseCtrl,
                  label: 'Expertise (comma separated)',
                  hint: 'Flutter, Dart, Mobile Architecture',
                  prefixIcon: Icons.star_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.minLength(v, 3, field: 'Expertise'),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _bioCtrl,
                  label: 'Short bio',
                  hint:
                  'Tell students about your teaching style and background.',
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      Validators.minLength(v, 20, field: 'Bio'),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton.primary(
                  label: 'Create Account',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}