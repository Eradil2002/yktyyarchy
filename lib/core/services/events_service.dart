import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../data/models/models.dart';

/// One page of events from DRF pagination (`results` + `next`).
class EventsPageResult {
  final List<VolunteerEvent> events;
  final bool hasMore;

  const EventsPageResult({
    required this.events,
    required this.hasMore,
  });
}

class EventsService {
  final ApiClient _apiClient;

  EventsService(this._apiClient);

  Future<Map<String, dynamic>> getEvents({
    String? category,
    String? type,
    String? status,
    bool? isUrgent,
    String? date,
    double? lat,
    double? lng,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (category != null) queryParams['category'] = category;
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (isUrgent != null) queryParams['is_urgent'] = isUrgent;
      if (date != null) queryParams['date'] = date;
      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;

      final response = await _apiClient.dio.get(
        'events/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to load events'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to load events'),
      };
    }
  }

  Future<EventsPageResult> getEventsPage({
    String? category,
    String? type,
    String? status,
    bool? isUrgent,
    String? date,
    double? lat,
    double? lng,
    int page = 1,
  }) async {
    final result = await getEvents(
      category: category,
      type: type,
      status: status,
      isUrgent: isUrgent,
      date: date,
      lat: lat,
      lng: lng,
      page: page,
    );
    if (result['success'] == true) {
      final data = result['data'];
      if (data is! Map) {
        return const EventsPageResult(events: [], hasMore: false);
      }
      final raw = List<Map<String, dynamic>>.from(data['results'] ?? []);
      final next = data['next'];
      final hasMore =
          next != null && next.toString().trim().isNotEmpty;
      return EventsPageResult(
        events: raw.map(VolunteerEvent.fromJson).toList(),
        hasMore: hasMore,
      );
    }
    throw Exception(result['error']?.toString() ?? 'Failed to load events');
  }

  Future<List<VolunteerEvent>> getEventsTyped({
    String? category,
    String? type,
    String? status,
    bool? isUrgent,
    String? date,
    double? lat,
    double? lng,
  }) async {
    final page = await getEventsPage(
      category: category,
      type: type,
      status: status,
      isUrgent: isUrgent,
      date: date,
      lat: lat,
      lng: lng,
      page: 1,
    );
    return page.events;
  }

  Future<Map<String, dynamic>> getEventById(int id) async {
    try {
      final response = await _apiClient.dio.get('events/$id/');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Event not found'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Event not found'),
      };
    }
  }

  Future<VolunteerEvent?> getEventByIdTyped(int id) async {
    final result = await getEventById(id);
    if (result['success'] == true && result['data'] is Map) {
      return VolunteerEvent.fromJson(Map<String, dynamic>.from(result['data']));
    }
    return null;
  }

  Future<Map<String, dynamic>> registerForEvent(int eventId) async {
    try {
      final response = await _apiClient.dio.post('events/$eventId/register/');

      if (response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Registration failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Registration failed'),
      };
    }
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('events/', data: data);

      if (response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to create event'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': ApiClient.formatError(e, fallback: 'Failed to create event'),
      };
    }
  }
}
