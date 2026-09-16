import 'auth_tokens.dart';
import 'auth_user.dart';

class LoginResponse {
  const LoginResponse({
    required this.tokens,
    required this.user,
  });

  final AuthTokens tokens;
  final AuthUser user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Accept both { data: {...} } and flat {...} envelopes.
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final tokensJson =
        (data['tokens'] as Map<String, dynamic>?) ?? data;
    final userJson = (data['user'] as Map<String, dynamic>?) ?? data;

    return LoginResponse(
      tokens: AuthTokens.fromJson(tokensJson),
      user: AuthUser.fromJson(userJson),
    );
  }
}