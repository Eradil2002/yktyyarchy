import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:volunteering/core/services/performance_service.dart';

class ApiClient {
  // Base URL is configurable via compile-time variables.
  static String get baseUrl {
    var url = const String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://api.yktyyarchy.kg/api/v1/',
    );
    if (!url.endsWith('/')) {
      url = '$url/';
    }
    if (url.endsWith('/api/') && !url.endsWith('/v1/')) {
      url = '${url}v1/';
    }
    return url;
  }

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Performance monitoring interceptor (#90)
    _dio.interceptors.add(PerformanceDioInterceptor());

    // Add interceptor for auth token

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the request
            return handler.resolve(await _retry(error.requestOptions));
          }
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        await clearTokens();
        return false;
      }

      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await refreshDio.post(
        'users/auth/token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await _storage.write(key: 'access_token', value: newAccessToken);
        // Server rotates refresh tokens: store the new one (old one is blacklisted)
        final newRefreshToken = response.data['refresh'];
        if (newRefreshToken != null) {
          await _storage.write(key: 'refresh_token', value: newRefreshToken);
        }
        return true;
      }

      // Refresh token is invalid or expired
      await clearTokens();
      return false;
    } catch (e) {
      // Clear tokens on any error
      await clearTokens();
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static String formatError(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      final detail = _extractDetail(data);
      if (detail != null && detail.isNotEmpty) return detail;

      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Session expired. Please sign in again.';
        case 403:
          return 'You do not have access to this action.';
        case 404:
          return 'Requested resource was not found.';
        case 500:
        case 502:
        case 503:
          return 'Server is temporarily unavailable.';
      }
      return 'Network request failed. Please check your internet connection.';
    }

    if (error is Exception) {
      final text = error.toString();
      if (text.startsWith('Exception: ')) {
        return text.replaceFirst('Exception: ', '');
      }
      return text;
    }

    return fallback;
  }

  static String? _extractDetail(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      if (data['detail'] != null) return data['detail'].toString();
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();

      // Handle field-specific errors: {"username": ["error1"]}
      final List<String> messages = [];
      data.forEach((key, value) {
        if (value is List) {
          messages.add('$key: ${value.join(", ")}');
        } else if (value is String) {
          messages.add('$key: $value');
        }
      });

      if (messages.isNotEmpty) return messages.join(". ");
    }
    return null;
  }
}
