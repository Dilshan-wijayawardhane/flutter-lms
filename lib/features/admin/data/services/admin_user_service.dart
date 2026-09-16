import '../../../../core/network/api_client.dart';
import '../../../student/data/models/user_profile.dart';

/// Admin-only user management endpoints.
class AdminUserService {
  AdminUserService(this._client);
  final ApiClient _client;

  static const String _path = '/api/v1/admin/users';

  Future<List<UserProfile>> list({
    String? search,
    String? role,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _client.get<dynamic>(
      _path,
      query: {
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        if (role != null && role.isNotEmpty) 'role': role,
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return _extractList(res)
        .whereType<Map<String, dynamic>>()
        .map(UserProfile.fromJson)
        .toList();
  }

  Future<UserProfile> get(String userId) async {
    final res = await _client.get<Map<String, dynamic>>(
      '$_path/$userId',
    );
    return UserProfile.fromJson(res);
  }

  Future<UserProfile> suspend(String userId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '$_path/$userId/suspend',
    );
    return UserProfile.fromJson(res);
  }

  Future<UserProfile> reactivate(String userId) async {
    final res = await _client.post<Map<String, dynamic>>(
      '$_path/$userId/reactivate',
    );
    return UserProfile.fromJson(res);
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        for (final key in ['items', 'results', 'users']) {
          if (data[key] is List) return data[key] as List;
        }
      }
      for (final key in ['items', 'results', 'users']) {
        if (res[key] is List) return res[key] as List;
      }
    }
    return const [];
  }
}