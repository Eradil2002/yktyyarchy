import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../data/models/models.dart';

class InitiativesService {
  final ApiClient _apiClient;

  InitiativesService(this._apiClient);

  Future<Map<String, dynamic>> getMyInitiatives() async {
    try {
      final userResponse = await _apiClient.dio.get('users/me/');
      final userId = userResponse.data['id'];
      final response = await _apiClient.dio.get('initiatives/');
      if (response.statusCode == 200) {
        final all = List<Map<String, dynamic>>.from(response.data);
        final mine = all.where((i) => i['creator'] == userId).toList();
        return {'success': true, 'data': mine};
      }
      return {'success': false, 'error': 'Failed to load initiatives'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to load initiatives'),
      };
    }
  }

  Future<List<Initiative>> getMyInitiativesTyped() async {
    final result = await getMyInitiatives();
    if (result['success'] == true) {
      final raw = List<Map<String, dynamic>>.from(result['data'] ?? []);
      return raw.map(Initiative.fromJson).toList();
    }
    throw Exception(result['error']?.toString() ?? 'Failed to load initiatives');
  }
}
