import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/mock_role.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/role_selector.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  MockRole _role = MockRole.student;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // Mock authentication — no real API call.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);

    AppSnackbar.showSuccess(context, 'Signed in as ${_role.label}');

    switch (_role) {
      case MockRole.student:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.studentDashboard,
        );
        break;
      case MockRole.instructor:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.instructorDashboard,
        );
        break;
      case MockRole.admin:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.adminDashboard,
        );
        break;
    }
  }

  void _openRegister() {
    switch (_role) {
      case MockRole.student:
        Navigator.of(context).pushNamed(AppRoutes.registerStudent);
        break;
      case MockRole.instructor:
        Navigator.of(context).pushNamed(AppRoutes.registerInstructor);
        break;
      case MockRole.admin:
        AppSnackbar.showInfo(context, 'Admin accounts are created by invite.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const AuthHeader(
                  title: 'Welcome back',
                  subtitle: 'Sign in to continue learning.',
                ),
                const SizedBox(height: AppSpacing.xl),

                Text('Sign in as', style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                RoleSelector(
                  selected: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),
                const SizedBox(height: AppSpacing.lg),

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
                  onSubmitted: (_) => _submit(),
                ),

                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.forgotPassword,
                    ),
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                AppButton.primary(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTextStyles.bodySmall,
                    ),
                    TextButton(
                      onPressed: _openRegister,
                      child: const Text('Register'),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Demo mode: any valid email + password signs in '
                              'with the selected role.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
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