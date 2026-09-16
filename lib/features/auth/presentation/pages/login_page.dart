import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../student/providers/profile_provider.dart';
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
import '../../providers/auth_provider.dart';
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String get _roleWireValue {
    switch (_role) {
      case MockRole.student:
        return 'STUDENT';
      case MockRole.instructor:
        return 'INSTRUCTOR';
      case MockRole.admin:
        return 'ADMIN';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final ok = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _roleWireValue,
    );

    if (!mounted) return;

    if (ok) {
      // Kick off the profile load so the dashboard/profile screens have data.
      context.read<ProfileProvider>().load(force: true);
      AppSnackbar.showSuccess(context, 'Signed in successfully');
      switch (_role) {
        case MockRole.student:
          Navigator.of(context)
              .pushReplacementNamed(AppRoutes.studentDashboard);
          break;
        case MockRole.instructor:
          Navigator.of(context)
              .pushReplacementNamed(AppRoutes.instructorDashboard);
          break;
        case MockRole.admin:
          Navigator.of(context)
              .pushReplacementNamed(AppRoutes.adminDashboard);
          break;
      }
    } else {
      AppSnackbar.showError(
        context,
        auth.errorMessage ?? 'Sign in failed. Please try again.',
      );
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
        AppSnackbar.showInfo(
          context,
          'Admin accounts are created by invite.',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

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
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.forgotPassword),
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                AppButton.primary(
                  label: 'Sign In',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}