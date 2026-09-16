import '../../../../core/network/api_client.dart';
import '../models/notification.dart';

class NotificationService {
  NotificationService(this._client);
  final ApiClient _client;

  Future<List<AppNotification>> list() async {
    final res = await _client.get<dynamic>('/api/v1/notifications');
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  Future<int> unreadCount() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/api/v1/notifications/unread-count',
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String id) async {
    await _client.post<dynamic>('/api/v1/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _client.post<dynamic>('/api/v1/notifications/read-all');
  }

  Future<void> delete(String id) async {
    await _client.delete<dynamic>('/api/v1/notifications/$id');
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['items'] is List) {
        return data['items'] as List;
      }
      if (data is Map<String, dynamic> && data['notifications'] is List) {
        return data['notifications'] as List;
      }
      if (res['items'] is List) return res['items'] as List;
      if (res['notifications'] is List) return res['notifications'] as List;
    }
    return const [];
  }
}