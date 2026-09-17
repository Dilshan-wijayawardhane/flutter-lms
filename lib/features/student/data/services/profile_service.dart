import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_profile.dart';

/// Talks to the shared user profile endpoints.
class ProfileService {
  ProfileService(this._client);

  final ApiClient _client;

  static const String _fullProfilePath =
      '/api/v1/users/me/full-profile';
  static const String _profileImagePath =
      '/api/v1/users/me/profile-image';

  /// GET /api/v1/users/me/full-profile
  Future<UserProfile> getFullProfile() async {
    final res = await _client.get<Map<String, dynamic>>(
      _fullProfilePath,
    );
    return UserProfile.fromJson(res);
  }

  /// Upload a new profile image.
  Future<String?> uploadProfileImage({
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final multipart = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: mimeType != null && mimeType.isNotEmpty
            ? MediaType.parse(mimeType)
            : null,
      );
      final form = FormData.fromMap({'image': multipart});

      final res = await _client.upload<Map<String, dynamic>>(
        _profileImagePath,
        formData: form,
        onSendProgress: onSendProgress,
      );

      final data = (res['data'] as Map<String, dynamic>?) ?? res;
      return (data['profileImageUrl'] ?? data['url'])?.toString();
    } on DioException catch (e) {
      throw ApiException.from(e.error ?? e);
    }
  }

  Future<void> deleteProfileImage() async {
    await _client.delete<dynamic>(_profileImagePath);
  }
}