import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.appName,
                style: AppTextStyles.displayMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Learn. Build. Grow.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}