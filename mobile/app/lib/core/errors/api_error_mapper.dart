import 'package:dio/dio.dart';

/// Maps [DioException] and other errors to short, user-facing messages.
String mapApiError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    final status = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Check your connection.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Check that the API is running and the base URL matches your device (see app_constants).';
      case DioExceptionType.badResponse:
        if (status == 401) {
          return 'Session expired or not authorized. Please sign in again.';
        }
        if (status == 404) return 'Resource not found.';
        if (status != null && status >= 500) {
          return 'Server error. Try again later.';
        }
        return 'Request failed${status != null ? ' ($status)' : ''}.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        break;
    }
  }
  return error.toString();
}
