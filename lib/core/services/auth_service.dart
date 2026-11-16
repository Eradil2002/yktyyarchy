import 'dart:convert';
import 'package:dio/dio.dart';
import '../api/api_client.dart';

class AuthActionResult {
  final bool success;
  final String? error;

  const AuthActionResult({required this.success, this.error});
}

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post(
        'users/auth/login/',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _apiClient.saveTokens(
          data['access'],
          data['refresh'],
        );
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': 'Login failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Login failed'),
      };
    }
  }

  Future<AuthActionResult> loginTyped(String username, String password) async {
    final result = await login(username, password);
    return AuthActionResult(
      success: result['success'] == true,
      error: result['error']?.toString(),
    );
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    String? phone,
    String role = 'volunteer',
    String? orgName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'users/auth/register/',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'role': role,
          if (orgName != null) 'org_name': orgName,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        await _apiClient.saveTokens(
          data['access'],
          data['refresh'],
        );
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': 'Registration failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Registration failed'),
      };
    }
  }

  Future<AuthActionResult> registerTyped({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    String? phone,
    String role = 'volunteer',
    String? orgName,
  }) async {
    final result = await register(
      username: username,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      role: role,
      orgName: orgName,
    );
    return AuthActionResult(
      success: result['success'] == true,
      error: result['error']?.toString(),
    );
  }

  Future<Map<String, dynamic>> verifyEmail(String code) async {
    try {
      final response = await _apiClient.dio.post(
        'users/auth/verify-email/',
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Verification failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Verification failed'),
      };
    }
  }

  Future<Map<String, dynamic>> resendVerificationCode() async {
    try {
      final response = await _apiClient.dio.post(
        'users/auth/resend-verification/',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': response.data['detail']};
      }
      return {'success': false, 'error': 'Failed to resend code'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to resend code'),
      };
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.dio.post(
        'users/auth/password-reset/',
        // Reset link base URL is configured on the server (FRONTEND_URL)
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': response.data['detail']};
      }
      return {'success': false, 'error': 'Failed to send reset email'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to send reset email'),
      };
    }
  }

  Future<Map<String, dynamic>> requestWhatsAppOtp(String phone) async {
    try {
      final response = await _apiClient.dio.post(
        'users/auth/whatsapp/request-otp/',
        data: {'phone': phone},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to request WhatsApp OTP'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to request WhatsApp OTP'),
      };
    }
  }

  Future<Map<String, dynamic>> verifyWhatsAppOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'users/auth/whatsapp/verify-otp/',
        data: {
          'phone': phone,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _apiClient.saveTokens(
          data['access'],
          data['refresh'],
        );
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': 'WhatsApp verification failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'WhatsApp verification failed'),
      };
    }
  }

  Future<AuthActionResult> verifyWhatsAppOtpTyped({
    required String phone,
    required String code,
  }) async {
    final result = await verifyWhatsAppOtp(phone: phone, code: code);
    return AuthActionResult(
      success: result['success'] == true,
      error: result['error']?.toString(),
    );
  }

  Future<void> logout() async {
    // Revoke the refresh token on the server, then clear local tokens
    try {
      final refresh = await _apiClient.getRefreshToken();
      if (refresh != null) {
        await _apiClient.dio.post('users/auth/logout/', data: {'refresh': refresh});
      }
    } catch (_) {
      // Ignore network errors: local logout must always succeed
    } finally {
      await _apiClient.clearTokens();
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset({
    required String uid,
    required String token,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'users/auth/password-reset-confirm/',
        data: {
          'uid': uid,
          'token': token,
          'new_password': password,
          'new_password_confirm': passwordConfirm,
        },
      );
      return {'success': response.statusCode == 200, 'message': response.data['detail']};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Не удалось сменить пароль'),
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getAccessToken();
    if (token == null) return false;
    
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      final exp = payload['exp'];
      if (exp == null) return true; 
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      return false;
    }
  }
}
