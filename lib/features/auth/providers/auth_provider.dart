import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/models/auth_user.dart';
import '../data/models/register_request.dart';
import '../data/models/verify_email_request.dart';
import '../data/services/auth_service.dart';

/// The single source of truth for authentication state.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service})
      : _service = service ?? AuthService(ApiClient.instance);

  final AuthService _service;

  // ---- State ----
  bool _isLoading = false;
  AuthUser? _user;
  String? _errorMessage;
  bool _isAuthenticated = false;
  bool _initialised = false;

  bool get isLoading => _isLoading;
  AuthUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get initialised => _initialised;

  // ---------------------------------------------------------------------------
  // Restore session on app start
  // ---------------------------------------------------------------------------
  Future<void> restoreSession() async {
    final has = await TokenStorage.instance.hasSession();
    if (has) {
      _isAuthenticated = true;
    }
    _initialised = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------
  Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final res = await _service.login(
        email: email,
        password: password,
        role: role,
      );
      _user = res.user;
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Student registration
  // ---------------------------------------------------------------------------
  Future<bool> registerStudent(RegisterRequest request) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.registerStudent(request);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Registration failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Instructor registration
  // ---------------------------------------------------------------------------
  Future<bool> registerInstructor(InstructorRegisterRequest request) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.registerInstructor(request);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Registration failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Verify email OTP
  // ---------------------------------------------------------------------------
  Future<bool> verifyEmail({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.verifyEmail(
        VerifyEmailRequest(email: email, otp: otp),
      );
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Verification failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Resend OTP
  // ---------------------------------------------------------------------------
  Future<bool> resendOtp({required String email}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.resendOtp(ResendOtpRequest(email: email));
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Could not resend the code. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}