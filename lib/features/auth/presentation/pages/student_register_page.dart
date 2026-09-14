import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/auth_header.dart';

class StudentRegisterPage extends StatefulWidget {
  const StudentRegisterPage({super.key});

  @override
  State<StudentRegisterPage> createState() => _StudentRegisterPageState();
}

class _StudentRegisterPageState extends State<StudentRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushNamed(
      AppRoutes.verifyEmail,
      arguments: _emailCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  title: 'Create Student Account',
                  subtitle: 'Join and start learning in minutes.',
                ),
                const SizedBox(height: AppSpacing.xl),

                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full name',
                  hint: 'Jane Doe',
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

                AppTextField(
                  controller: _phoneCtrl,
                  label: 'Phone (optional)',
                  hint: '+1 555 123 4567',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.phone,
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
                  validator: (v) => Validators.confirmPassword(
                    v,
                    _passwordCtrl.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton.primary(
                  label: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),

                Center(
                  child: Text(
                    'By continuing, you agree to our Terms and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}