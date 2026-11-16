import 'package:flutter/foundation.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/providers/mixins/error_handling_mixin.dart';
import '../services/auth_service.dart';
import '../services/users_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier, ErrorHandlingMixin {
  final AuthService _authService;
  final UsersService _usersService;
  final NotificationService? _notificationService;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  VolunteerUser? _currentUser;

  AuthProvider(this._authService, this._usersService, [this._notificationService]) {
    _checkAuthStatus();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  VolunteerUser? get currentUser => _currentUser;
  UsersService get usersService => _usersService;

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isLoggedIn();

      if (_isAuthenticated) {
        await loadCurrentUser();
        // Register device in background without blocking
        _notificationService?.registerDevice().catchError((e) {
          if (kDebugMode) {
            print('Device registration failed: $e');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auth status: $e');
      }
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.loginTyped(username, password);

      if (result.success) {
        _isAuthenticated = true;
        await loadCurrentUser();
        // Register device in background without blocking login
        _notificationService?.registerDevice().catchError((e) {
          if (kDebugMode) {
            print('Device registration failed: $e');
          }
        });
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = mapError(e, fallback: 'Login failed');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.registerTyped(
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

      if (result.success) {
        _isAuthenticated = true;
        await loadCurrentUser();
        // Register device in background without blocking
        _notificationService?.registerDevice().catchError((e) {
          if (kDebugMode) {
            print('Device registration failed: $e');
          }
        });
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = mapError(e, fallback: 'Registration failed');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      return await _authService.requestPasswordReset(email);
    } catch (e) {
      return {
        'success': false,
        'error': mapError(e, fallback: 'Password reset failed'),
      };
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String code) async {
    try {
      return await _authService.verifyEmail(code);
    } catch (e) {
      return {
        'success': false,
        'error': mapError(e, fallback: 'Email verification failed'),
      };
    }
  }

  Future<Map<String, dynamic>> resendVerificationCode() async {
    try {
      return await _authService.resendVerificationCode();
    } catch (e) {
      return {
        'success': false,
        'error': mapError(e, fallback: 'Resend verification failed'),
      };
    }
  }

  Future<Map<String, dynamic>> requestWhatsAppOtp(String phone) async {
    try {
      return await _authService.requestWhatsAppOtp(phone);
    } catch (e) {
      return {
        'success': false,
        'error': mapError(e, fallback: 'WhatsApp OTP request failed'),
      };
    }
  }

  Future<bool> loginWithWhatsApp({
    required String phone,
    required String code,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.verifyWhatsAppOtpTyped(
        phone: phone,
        code: code,
      );
      if (result.success) {
        _isAuthenticated = true;
        await loadCurrentUser();
        _notificationService?.registerDevice().catchError((_) {});
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = result.error;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = mapError(e, fallback: 'WhatsApp login failed');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final user = await _usersService.getMyProfileModel();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      } else {
        final cachedUser = await _usersService.getCachedMyProfileModel();
        if (cachedUser != null) {
          _currentUser = cachedUser;
          notifyListeners();
          return;
        }
        if (kDebugMode) {
          print('Failed to load user profile');
        }
      }
    } catch (e) {
      final cachedUser = await _usersService.getCachedMyProfileModel();
      if (cachedUser != null) {
        _currentUser = cachedUser;
        notifyListeners();
        return;
      }
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? location,
    String? bio,
    List<String>? skills,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _usersService.updateProfileFields(
        firstName: firstName,
        lastName: lastName,
        location: location,
        bio: bio,
        skills: skills,
      );

      _isLoading = false;
      if (result['success'] == true) {
        await loadCurrentUser();
        return true;
      } else {
        _error = result['error'] ?? 'Profile update failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = mapError(e, fallback: 'Profile update failed');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
