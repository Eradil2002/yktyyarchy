import 'package:dio/dio.dart';
import '../api/api_client.dart';
import 'offline_cache_service.dart';
import '../../data/models/models.dart';

class UsersService {
  final ApiClient _apiClient;
  final OfflineCacheService _offlineCacheService = OfflineCacheService();

  UsersService(this._apiClient);

  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get('users/me/');

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        await _offlineCacheService.saveMyProfile(data);
        return {'success': true, 'data': data, 'from_cache': false};
      }
      return {'success': false, 'error': 'Failed to load profile'};
    } on DioException catch (e) {
      // Offline fallback: if network is down, return latest cached profile.
      if (_isNetworkError(e)) {
        final cached = await _offlineCacheService.loadMyProfile();
        if (cached != null) {
          return {'success': true, 'data': cached, 'from_cache': true};
        }
      }
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to load profile'),
      };
    }
  }

  Future<VolunteerUser?> getCachedMyProfileModel() async {
    final cached = await _offlineCacheService.loadMyProfile();
    if (cached == null) return null;
    return VolunteerUser.fromJson(cached);
  }

  bool _isNetworkError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return true;
    }
    // If there is no server response at all, treat it as network outage.
    return e.response == null;
  }

  Future<VolunteerUser?> getMyProfileModel() async {
    final result = await getMyProfile();
    if (result['success'] == true && result['data'] is Map) {
      return VolunteerUser.fromJson(Map<String, dynamic>.from(result['data']));
    }
    return null;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('users/me/', data: data);

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to update profile'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to update profile'),
      };
    }
  }

  Future<Map<String, dynamic>> updateProfileMultipart({
    String? firstName,
    String? lastName,
    String? location,
    String? bio,
    List<String>? skills,
    String? avatarPath,
  }) async {
    try {
      final payload = FormData.fromMap({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (location != null) 'location': location,
        if (bio != null) 'bio': bio,
        if (skills != null) 'skills': skills,
        if (avatarPath != null && avatarPath.isNotEmpty)
          'avatar': await MultipartFile.fromFile(avatarPath),
      });

      final response = await _apiClient.dio.patch(
        'users/me/',
        data: payload,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to update profile'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to update profile'),
      };
    }
  }

  Future<VolunteerUser?> updateProfileMultipartModel({
    String? firstName,
    String? lastName,
    String? location,
    String? bio,
    List<String>? skills,
    String? avatarPath,
  }) async {
    final result = await updateProfileMultipart(
      firstName: firstName,
      lastName: lastName,
      location: location,
      bio: bio,
      skills: skills,
      avatarPath: avatarPath,
    );
    if (result['success'] == true && result['data'] is Map) {
      return VolunteerUser.fromJson(Map<String, dynamic>.from(result['data']));
    }
    return null;
  }

  /// Convenience wrapper with named parameters.
  Future<Map<String, dynamic>> updateProfileFields({
    String? firstName,
    String? lastName,
    String? location,
    String? bio,
    List<String>? skills,
  }) =>
      updateProfile({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (location != null) 'location': location,
        if (bio != null) 'bio': bio,
        if (skills != null) 'skills': skills,
      });

  Future<Map<String, dynamic>> getUserById(int id) async {
    try {
      final response = await _apiClient.dio.get('users/$id/');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'User not found'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'User not found'),
      };
    }
  }

  Future<Map<String, dynamic>> getVolunteers() async {
    try {
      final response = await _apiClient.dio.get('users/volunteers/');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to load volunteers'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to load volunteers'),
      };
    }
  }
}
