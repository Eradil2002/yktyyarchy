import 'package:dio/dio.dart';
import '../api/api_client.dart';

class NotificationsService {
  final ApiClient _apiClient;

  NotificationsService(this._apiClient);

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('notifications/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to load notifications'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to load notifications'),
      };
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      final response = await _apiClient.dio.post('notifications/$id/mark_as_read/');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.post('notifications/mark_all_as_read/');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
