import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushNamed(
      AppRoutes.resetPassword,
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
                  title: 'Forgot password?',
                  subtitle:
                  'Enter your email and we will send you a reset code.',
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: Validators.email,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton.primary(
                  label: 'Send reset code',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}