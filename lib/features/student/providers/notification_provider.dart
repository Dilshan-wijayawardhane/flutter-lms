import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../data/models/notification.dart';
import '../data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationService? service})
      : _service = service ?? NotificationService(ApiClient.instance);

  final NotificationService _service;

  LoadState _state = LoadState.initial;
  List<AppNotification> _notifications = const [];
  String? _errorMessage;

  LoadState get state => _state;
  List<AppNotification> get notifications => _notifications;
  String? get errorMessage => _errorMessage;
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<void> load({bool force = false}) async {
    if (_state == LoadState.loading) return;
    if (!force && _state == LoadState.success) return;

    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _service.list();
      _state = LoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = LoadState.error;
    } catch (_) {
      _errorMessage = 'Could not load notifications.';
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx < 0 || _notifications[idx].isRead) return;

    // Optimistic local update.
    _notifications = [
      for (var i = 0; i < _notifications.length; i++)
        i == idx
            ? _notifications[i].copyWith(isRead: true)
            : _notifications[i],
    ];
    notifyListeners();

    try {
      await _service.markRead(id);
    } catch (_) {
      // Revert if the backend rejects.
      _notifications = [
        for (var i = 0; i < _notifications.length; i++)
          i == idx
              ? _notifications[i].copyWith(isRead: false)
              : _notifications[i],
      ];
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    final previous = _notifications;
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    try {
      await _service.markAllRead();
    } catch (_) {
      _notifications = previous;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    final previous = _notifications;
    _notifications = _notifications.where((n) => n.id != id).toList();
    notifyListeners();

    try {
      await _service.delete(id);
    } catch (_) {
      _notifications = previous;
      notifyListeners();
    }
  }
}