import '../../../../core/network/api_client.dart';
import '../models/user_profile.dart';

/// Talks to the shared user profile endpoints.
class ProfileService {
  ProfileService(this._client);

  final ApiClient _client;

  static const String _fullProfilePath =
      '/api/v1/users/me/full-profile';

  /// GET /api/v1/users/me/full-profile
  Future<UserProfile> getFullProfile() async {
    final res = await _client.get<Map<String, dynamic>>(
      _fullProfilePath,
    );
    return UserProfile.fromJson(res);
  }
}