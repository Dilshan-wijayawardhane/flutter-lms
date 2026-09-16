import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/verify_email_request.dart';

/// Thin wrapper around the auth endpoints. This is the ONLY place that
/// knows the exact auth paths and request shapes.
class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  // ---------------------------------------------------------------------------
  // Endpoints (adjust here if Postman says otherwise — nowhere else)
  // ---------------------------------------------------------------------------
  static const String _loginPath = '/api/v1/auth/login';
  static const String _studentRegisterPath = '/api/v1/auth/register/student';
  static const String _instructorRegisterPath =
      '/api/v1/auth/register/instructor';
  static const String _verifyEmailPath = '/api/v1/auth/verify-email';
  static const String _resendOtpPath = '/api/v1/auth/resend-otp';
  static const String _logoutPath = '/api/v1/auth/logout';
  static const String _refreshPath = '/api/v1/auth/refresh';

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------
  Future<LoginResponse> login({
    required String email,
    required String password,
    required String role, // 'STUDENT' | 'INSTRUCTOR' | 'ADMIN'
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      _loginPath,
      data: {
        'email': email.trim(),
        'password': password,
        'role': role,
      },
    );
    final parsed = LoginResponse.fromJson(res);

    // Persist tokens + user metadata. TokenStorage is the only writer.
    await TokenStorage.instance.saveAccessToken(parsed.tokens.accessToken);
    await TokenStorage.instance.saveRefreshToken(parsed.tokens.refreshToken);
    await TokenStorage.instance.saveUserId(parsed.user.id);
    await TokenStorage.instance.saveUserRole(parsed.user.role);

    return parsed;
  }

  // ---------------------------------------------------------------------------
  // Student registration
  // ---------------------------------------------------------------------------
  Future<void> registerStudent(RegisterRequest request) async {
    await _client.post<Map<String, dynamic>>(
      _studentRegisterPath,
      data: request.toJson(),
    );
  }

  // ---------------------------------------------------------------------------
  // Instructor registration
  // ---------------------------------------------------------------------------
  Future<void> registerInstructor(InstructorRegisterRequest request) async {
    await _client.post<Map<String, dynamic>>(
      _instructorRegisterPath,
      data: request.toJson(),
    );
  }

  // ---------------------------------------------------------------------------
  // OTP
  // ---------------------------------------------------------------------------
  Future<void> verifyEmail(VerifyEmailRequest request) async {
    await _client.post<Map<String, dynamic>>(
      _verifyEmailPath,
      data: request.toJson(),
    );
  }

  Future<void> resendOtp(ResendOtpRequest request) async {
    await _client.post<Map<String, dynamic>>(
      _resendOtpPath,
      data: request.toJson(),
    );
  }

  // ---------------------------------------------------------------------------
  // Logout (best-effort; we always clear local tokens)
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    try {
      await _client.post<Map<String, dynamic>>(_logoutPath);
    } on ApiException {
      // Ignore server-side logout failures. Local state clears regardless.
    } finally {
      await TokenStorage.instance.clear();
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh (used later in Phase 7 by the interceptor)
  // ---------------------------------------------------------------------------
  Future<void> refreshTokens() async {
    final refresh = await TokenStorage.instance.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw const ApiException(message: 'No refresh token available.');
    }
    final res = await _client.post<Map<String, dynamic>>(
      _refreshPath,
      data: {'refreshToken': refresh},
    );
    final tokens = LoginResponse.fromJson(res).tokens;
    await TokenStorage.instance.saveAccessToken(tokens.accessToken);
    await TokenStorage.instance.saveRefreshToken(tokens.refreshToken);
  }
}