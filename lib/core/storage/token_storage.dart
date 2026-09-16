import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for authentication tokens and the current user's ID.
///
/// Backed by Keychain (iOS) / EncryptedSharedPreferences (Android).
class TokenStorage {
  TokenStorage._internal();

  static final TokenStorage instance = TokenStorage._internal();

  // ---- Storage keys ----
  static const String _kAccessToken = 'lms.access_token';
  static const String _kRefreshToken = 'lms.refresh_token';
  static const String _kUserId = 'lms.user_id';
  static const String _kUserRole = 'lms.user_role';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ---- Access token ----
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  // ---- Refresh token ----
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  // ---- User ID ----
  Future<void> saveUserId(String userId) =>
      _storage.write(key: _kUserId, value: userId);

  Future<String?> getUserId() => _storage.read(key: _kUserId);

  // ---- User role ----
  Future<void> saveUserRole(String role) =>
      _storage.write(key: _kUserRole, value: role);

  Future<String?> getUserRole() => _storage.read(key: _kUserRole);

  // ---- Session helpers ----
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Wipes every authentication-related key. Call this on logout or when
  /// refresh fails.
  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUserRole);
  }
}