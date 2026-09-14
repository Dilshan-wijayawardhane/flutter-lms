import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../mock_data/mock_notifications.dart';
import '../../../../mock_data/models/mock_notification.dart';

class StudentNotificationDetailsPage extends StatelessWidget {
  const StudentNotificationDetailsPage({
    super.key,
    required this.notificationId,
  });

  final String notificationId;

  @override
  Widget build(BuildContext context) {
    final n = _find(notificationId);
    if (n == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Notification not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notification')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                        ),
                        child: Text(
                          n.type.wireValue,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.dateTime(n.createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(n.title, style: AppTextStyles.headingSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(n.message, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MockNotification? _find(String id) {
    for (final n in MockNotifications.all) {
      if (n.id == id) return n;
    }
    return null;
  }
}