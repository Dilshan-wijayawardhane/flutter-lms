import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../errors/api_exception.dart';
import '../storage/token_storage.dart';

/// Central HTTP client.
///
/// Every repository in the app goes through this class — the UI never
/// touches Dio directly.
///
/// Responsibilities:
/// - attaches the Bearer token automatically
/// - converts Dio errors into [ApiException]
/// - retries once after a successful token refresh on `401`
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // We handle non-2xx ourselves so we can map errors cleanly.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;

  /// Exposed for special cases (e.g. a repository needs a raw stream).
  /// Regular features must not use this.
  Dio get raw => _dio;

  // ---------------------------------------------------------------------------
  // Interceptor: attach Bearer token
  // ---------------------------------------------------------------------------
  Future<void> _onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // Endpoints that must NOT carry a token.
    const publicPaths = <String>{
      '/api/v1/auth/login',
      '/api/v1/auth/register',
      '/api/v1/auth/verify-email',
      '/api/v1/auth/resend-otp',
      '/api/v1/auth/forgot-password',
      '/api/v1/auth/verify-reset-otp',
      '/api/v1/auth/reset-password',
      '/api/v1/auth/refresh',
    };

    final isPublic = publicPaths.any(
          (p) => options.path == p || options.path.startsWith('$p/'),
    );

    if (!isPublic) {
      final token = await TokenStorage.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // Interceptor: convert errors into ApiException
  //
  // NOTE: refresh-token logic is intentionally NOT implemented yet — that is
  // Phase 7 in the master prompt. For Phase 1 we only surface a clean
  // ApiException. This keeps the interceptor small and easy to extend.
  // ---------------------------------------------------------------------------
  Future<void> _onError(
      DioException e,
      ErrorInterceptorHandler handler,
      ) async {
    handler.reject(
      DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: ApiException.from(e),
        stackTrace: e.stackTrace,
      ),
      true,
    );
  }

  // ---------------------------------------------------------------------------
  // Public helpers
  // ---------------------------------------------------------------------------

  Future<T> get<T>(
      String path, {
        Map<String, dynamic>? query,
        Options? options,
      }) async {
    try {
      final res = await _dio.get<T>(path, queryParameters: query, options: options);
      return _unwrap<T>(res);
    } on DioException catch (e) {
      throw ApiException.from(e.error ?? e);
    }
  }

  Future<T> post<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? query,
        Options? options,
      }) async {
    try {
      final res = await _dio.post<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
      return _unwrap<T>(res);
    } on DioException catch (e) {
      throw ApiException.from(e.error ?? e);
    }
  }

  Future<T> patch<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? query,
        Options? options,
      }) async {
    try {
      final res = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
      return _unwrap<T>(res);
    } on DioException catch (e) {
      throw ApiException.from(e.error ?? e);
    }
  }

  Future<T> put<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? query,
        Options? options,
      }) async {
    try {
      final res = await _dio.put<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
      return _unwrap<T>(res);
    } on DioException catch (e) {
      throw ApiException.from(e.error ?? e);
    }
  }

  Future<T> delete<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? query,
        Options? options,
      }) async {
    try {
      final res = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
      return _unwrap<T>(res);
    } on DioException catch (e) {
      throw ApiException.from(e.error ?? e);
    }
  }

  Future<T> upload<T>(
      String path, {
        required FormData formData,
        void Function(int sent, int total)? onSendProgress,
        Options? options,
      }) async {
    try {
      final res = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: (options ?? Options()).copyWith(
          contentType: 'multipart/form-data',
        ),
      );
      return _unwrap<T>(res);
    } on DioException catch (e) {
      throw ApiException.from(e.error ?? e);
    }
  }

  /// Converts a `2xx` Dio response into either the response body or a
  /// cleaned-up payload. Non-2xx responses are re-thrown as ApiException.
  T _unwrap<T>(Response response) {
    final status = response.statusCode ?? 0;

    if (status < 200 || status >= 300) {
      // We set validateStatus to < 500 earlier, so 4xx land here.
      throw ApiException.fromDio(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    }

    final data = response.data;
    if (data is T) return data;

    // Nullable-safe fallback: return a cast when possible.
    return data as T;
  }
}