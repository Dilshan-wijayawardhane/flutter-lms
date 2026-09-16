import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/load_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/notification.dart';
import '../../providers/notification_provider.dart';

class StudentNotificationsPage extends StatefulWidget {
  const StudentNotificationsPage({super.key});

  @override
  State<StudentNotificationsPage> createState() =>
      _StudentNotificationsPageState();
}

class _StudentNotificationsPageState
    extends State<StudentNotificationsPage> {
  int _filter = 0; // 0 = All, 1 = Unread

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<NotificationProvider>();
      if (p.state != LoadState.success) p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Row(
              children: [
                _chip('All', 0),
                const SizedBox(width: AppSpacing.xs),
                _chip('Unread', 1),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(top: false, child: _buildBody(provider)),
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    if (provider.state == LoadState.loading &&
        provider.notifications.isEmpty) {
      return const AppLoading(message: 'Loading notifications…');
    }
    if (provider.state == LoadState.error &&
        provider.notifications.isEmpty) {
      return AppErrorState(
        title: 'Could not load notifications',
        message: provider.errorMessage ?? 'Please try again.',
        onRetry: () => provider.load(force: true),
      );
    }

    final list = _filter == 0
        ? provider.notifications
        : provider.notifications.where((n) => !n.isRead).toList();

    if (list.isEmpty) {
      return const AppEmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications',
        message: 'You will see updates about your courses here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.load(force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final n = list[i];
          return Dismissible(
            key: ValueKey(n.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius:
                BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) => provider.delete(n.id),
            child: _notificationCard(n, provider),
          );
        },
      ),
    );
  }

  Widget _notificationCard(
      AppNotification n,
      NotificationProvider provider,
      ) {
    final unread = !n.isRead;
    return Material(
      color: unread ? AppColors.primarySurface : AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () {
          if (unread) provider.markRead(n.id);
          Navigator.of(context).pushNamed(
            AppRoutes.studentNotificationDetails,
            arguments: n.id,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: unread
                  ? AppColors.primaryLight
                  : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: unread
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  _icon(n.type),
                  size: 20,
                  color:
                  unread ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title,
                              style: AppTextStyles.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(Formatters.relative(n.createdAt),
                            style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      n.message,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  height: 8,
                  width: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.course:
        return Icons.menu_book_outlined;
      case NotificationType.assignment:
        return Icons.assignment_outlined;
      case NotificationType.quiz:
        return Icons.quiz_outlined;
      case NotificationType.enrollment:
        return Icons.how_to_reg_outlined;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  Widget _chip(String label, int index) {
    final active = _filter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primarySurface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: active ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: active
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}