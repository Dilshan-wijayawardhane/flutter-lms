import 'package:dio/dio.dart';

/// A single, human-readable exception type that every repository throws.
///
/// The UI never sees Dio errors, stack traces, or raw backend JSON — only
/// [ApiException] with a clean [message].
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
    this.isNetworkError = false,
    this.isUnauthorized = false,
    this.isForbidden = false,
    this.isNotFound = false,
    this.isValidationError = false,
    this.isServerError = false,
    this.isTimeout = false,
    this.isTooManyRequests = false,
  });

  /// A clean, user-displayable message.
  final String message;

  /// HTTP status code, if the error came from a response.
  final int? statusCode;

  /// Backend `errorCode` field, if present.
  final String? errorCode;

  /// Backend `details` field, if present. Useful for field-level errors.
  final Map<String, dynamic>? details;

  final bool isNetworkError;
  final bool isUnauthorized;
  final bool isForbidden;
  final bool isNotFound;
  final bool isValidationError;
  final bool isServerError;
  final bool isTimeout;
  final bool isTooManyRequests;

  /// Converts an arbitrary object (usually a Dio error) into an ApiException.
  factory ApiException.from(Object error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      return ApiException.fromDio(error);
    }

    return const ApiException(
      message: 'Something went wrong. Please try again.',
    );
  }

  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;

    // ---- Parse the backend's standard envelope ----
    String? backendMessage;
    String? backendErrorCode;
    Map<String, dynamic>? backendDetails;

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) {
        backendMessage = data['message'] as String;
      }
      if (data['errorCode'] is String) {
        backendErrorCode = data['errorCode'] as String;
      }
      if (data['details'] is Map<String, dynamic>) {
        backendDetails = data['details'] as Map<String, dynamic>;
      }
    } else if (data is String && data.isNotEmpty) {
      // Some backends return a plain string body.
      backendMessage = data;
    }

    // ---- Network-level failures (no response) ----
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          message: 'Request timed out. Please try again.',
          isTimeout: true,
          isNetworkError: true,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Network connection failed. Please check your internet '
              'and try again.',
          isNetworkError: true,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Secure connection could not be verified.',
          isNetworkError: true,
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled.');
      case DioExceptionType.unknown:
        return ApiException(
          message:
          backendMessage ?? 'Network connection failed. Please try again.',
          isNetworkError: true,
        );
      case DioExceptionType.badResponse:
        break;
    }

    // ---- HTTP status mapping ----
    switch (status) {
      case 400:
        return ApiException(
          message: backendMessage ?? 'Invalid request.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
        );
      case 401:
        return ApiException(
          message: backendMessage ?? 'Session expired. Please log in again.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
          isUnauthorized: true,
        );
      case 403:
        return ApiException(
          message: backendMessage ??
              'You are not authorized to perform this action.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
          isForbidden: true,
        );
      case 404:
        return ApiException(
          message: backendMessage ?? 'Resource not found.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
          isNotFound: true,
        );
      case 409:
        return ApiException(
          message:
          backendMessage ?? 'Conflict. This resource already exists.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
        );
      case 422:
        return ApiException(
          message: backendMessage ?? 'Please check the highlighted fields.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
          isValidationError: true,
        );
      case 429:
        return ApiException(
          message: backendMessage ??
              'Too many requests. Please wait and try again.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
          isTooManyRequests: true,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException(
          message:
          backendMessage ?? 'Server unavailable. Please try again later.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
          isServerError: true,
        );
      default:
        return ApiException(
          message: backendMessage ??
              'Unexpected error (${status ?? 'unknown'}). Please try again.',
          statusCode: status,
          errorCode: backendErrorCode,
          details: backendDetails,
        );
    }
  }

  @override
  String toString() =>
      'ApiException(status: $statusCode, code: $errorCode, message: $message)';
}