import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../widgets/auth_header.dart';
import '../widgets/otp_input_field.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  String _otp = '';
  bool _hasError = false;
  bool _isVerifying = false;
  int _resendCooldown = AppConstants.otpResendSeconds;
  Timer? _timer;

  String _email = '';

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

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
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _resendCooldown = AppConstants.otpResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendCooldown <= 1) {
        t.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  void _onResend() {
    if (_resendCooldown > 0) return;
    AppSnackbar.showInfo(context, 'A new code has been sent.');
    _startCooldown();
  }

  Future<void> _verify() async {
    final error = Validators.otp(_otp);
    if (error != null) {
      setState(() => _hasError = true);
      AppSnackbar.showError(context, error);
      return;
    }
    setState(() {
      _hasError = false;
      _isVerifying = true;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isVerifying = false);
    AppSnackbar.showSuccess(context, 'Email verified successfully.');
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                title: 'Verify your email',
                subtitle:
                'Enter the 6-digit code we sent to your inbox.',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_email.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mail_outline_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          _email,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),

              OtpInputField(
                hasError: _hasError,
                onChanged: (v) => setState(() => _otp = v),
                onCompleted: (_) => _verify(),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppButton.primary(
                label: 'Verify',
                isLoading: _isVerifying,
                onPressed: _verify,
              ),
              const SizedBox(height: AppSpacing.md),

              Center(
                child: _resendCooldown > 0
                    ? Text(
                  'Resend code in ${_resendCooldown}s',
                  style: AppTextStyles.bodySmall,
                )
                    : TextButton(
                  onPressed: _onResend,
                  child: const Text('Resend code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}