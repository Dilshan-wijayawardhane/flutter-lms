import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../mock_data/mock_notifications.dart';
import '../../../../mock_data/models/mock_notification.dart';
import '../widgets/notification_card.dart';

class StudentNotificationsPage extends StatefulWidget {
  const StudentNotificationsPage({super.key});

  @override
  State<StudentNotificationsPage> createState() =>
      _StudentNotificationsPageState();
}

class _StudentNotificationsPageState
    extends State<StudentNotificationsPage> {
  late List<MockNotification> _all;
  int _filter = 0; // 0=All, 1=Unread

  @override
  void initState() {
    super.initState();
    _all = List.of(MockNotifications.student1);
  }

  List<MockNotification> get _visible {
    if (_filter == 0) return _all;
    return _all.where((n) => !n.isRead).toList();
  }

  int get _unreadCount => _all.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _all = _all.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
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
      body: SafeArea(
        top: false,
        child: list.isEmpty
            ? const AppEmptyState(
          icon: Icons.notifications_none_rounded,
          title: 'No notifications',
          message:
          'You will see updates about your courses here.',
        )
            : ListView.separated(
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
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusMd,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
              onDismissed: (_) {
                setState(() {
                  _all.removeWhere((x) => x.id == n.id);
                });
              },
              child: NotificationCard(
                notification: n,
                onTap: () {
                  // Mark as read locally when opened.
                  if (!n.isRead) {
                    setState(() {
                      final idx =
                      _all.indexWhere((x) => x.id == n.id);
                      if (idx != -1) {
                        _all[idx] =
                            _all[idx].copyWith(isRead: true);
                      }
                    });
                  }
                  Navigator.of(context).pushNamed(
                    AppRoutes.studentNotificationDetails,
                    arguments: n.id,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
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