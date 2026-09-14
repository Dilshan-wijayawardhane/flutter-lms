import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/otp_input_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _otp = '';
  bool _hasOtpError = false;
  bool _isLoading = false;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _email = args;
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final otpError = Validators.otp(_otp);
    if (otpError != null) {
      setState(() => _hasOtpError = true);
      AppSnackbar.showError(context, otpError);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _hasOtpError = false;
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);

    AppSnackbar.showSuccess(context, 'Password reset. Please sign in.');
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
          (_) => false,
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
                AuthHeader(
                  title: 'Reset password',
                  subtitle: _email.isEmpty
                      ? 'Enter the code we sent and set a new password.'
                      : 'Enter the code sent to $_email and set a new password.',
                ),
                const SizedBox(height: AppSpacing.xl),

                Text('Verification code',
                    style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                OtpInputField(
                  hasError: _hasOtpError,
                  onChanged: (v) => setState(() => _otp = v),
                ),
                const SizedBox(height: AppSpacing.lg),

                AppPasswordField(
                  controller: _passwordCtrl,
                  label: 'New password',
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),

                AppPasswordField(
                  controller: _confirmCtrl,
                  label: 'Confirm new password',
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordCtrl.text),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton.primary(
                  label: 'Reset Password',
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