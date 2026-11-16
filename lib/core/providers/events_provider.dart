import 'package:flutter/foundation.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/providers/mixins/error_handling_mixin.dart';
import '../services/offline_cache_service.dart';
import '../services/events_service.dart';

class EventsProvider with ChangeNotifier, ErrorHandlingMixin {
  final EventsService _eventsService;
  final OfflineCacheService _offlineCacheService = OfflineCacheService();

  List<VolunteerEvent> _events = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  bool _loadedFromCache = false;

  int _currentPage = 1;
  bool _hasMore = true;

  String? _filterCategory;
  String? _filterType;
  String? _filterStatus;
  bool? _filterUrgent;
  String? _filterDate;
  double? _filterLat;
  double? _filterLng;

  EventsProvider(this._eventsService);

  List<VolunteerEvent> get events => _events;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get loadedFromCache => _loadedFromCache;
  bool get hasMore => _hasMore;

  Future<void> loadEvents({
    String? category,
    String? type,
    String? status,
    bool? isUrgent,
    String? date,
    double? lat,
    double? lng,
  }) async {
    _filterCategory = category;
    _filterType = type;
    _filterStatus = status;
    _filterUrgent = isUrgent;
    _filterDate = date;
    _filterLat = lat;
    _filterLng = lng;

    _currentPage = 1;
    _hasMore = true;

    _isLoading = true;
    _error = null;
    _loadedFromCache = false;
    notifyListeners();

    final cached = await _offlineCacheService.loadEventsFeed();
    if (cached.isNotEmpty) {
      _events = cached
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(VolunteerEvent.fromJson)
          .toList();
      _loadedFromCache = true;
      _isLoading = false;
      notifyListeners();
    }

    try {
      final page = await _eventsService.getEventsPage(
        category: _filterCategory,
        type: _filterType,
        status: _filterStatus,
        isUrgent: _filterUrgent,
        date: _filterDate,
        lat: _filterLat,
        lng: _filterLng,
        page: 1,
      );
      _events = page.events;
      _hasMore = page.hasMore;
      _currentPage = 1;
      final rawEvents = _eventsServiceDataForCache(_events);
      await _offlineCacheService.saveEventsFeed(rawEvents);
      _loadedFromCache = false;
    } catch (e) {
      if (_events.isEmpty) {
        _error = mapError(e, fallback: 'Failed to load events');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreEvents() async {
    if (!_hasMore || _isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final page = await _eventsService.getEventsPage(
        category: _filterCategory,
        type: _filterType,
        status: _filterStatus,
        isUrgent: _filterUrgent,
        date: _filterDate,
        lat: _filterLat,
        lng: _filterLng,
        page: _currentPage + 1,
      );
      _currentPage++;
      _events = [..._events, ...page.events];
      _hasMore = page.hasMore;
      await _offlineCacheService.saveEventsFeed(_eventsServiceDataForCache(_events));
    } catch (e) {
      _error = mapError(e, fallback: 'Failed to load events');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<VolunteerEvent?> getEventById(int id) async {
    return _eventsService.getEventByIdTyped(id);
  }

  Future<void> _reloadPreservingFilters() async {
    await loadEvents(
      category: _filterCategory,
      type: _filterType,
      status: _filterStatus,
      isUrgent: _filterUrgent,
      date: _filterDate,
      lat: _filterLat,
      lng: _filterLng,
    );
  }

  Future<bool> registerForEvent(int eventId) async {
    final result = await _eventsService.registerForEvent(eventId);
    if (result['success']) {
      await _reloadPreservingFilters();
      return true;
    }
    return false;
  }

  Future<bool> createEvent(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _eventsService.createEvent(data);
    _isLoading = false;

    if (result['success']) {
      await _reloadPreservingFilters();
      return true;
    } else {
      _error = mapError(Exception(result['error']?.toString() ?? 'Failed to create event'));
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> _eventsServiceDataForCache(List<VolunteerEvent> events) {
    return events
        .map((e) => <String, dynamic>{
              'id': e.id,
              'title': e.title,
              'description': e.description,
              'organizer': e.organizerId,
              'category': e.categoryId,
              'date': e.date.toIso8601String(),
              'end_time': e.endTime,
              'location': e.location,
              'type': e.type == EventType.online ? 'online' : 'offline',
              'hours': e.hours,
              'spots_total': e.spotsTotal,
              'spots_booked': e.spotsBooked,
              'requirements': e.requirements,
              'status': e.status.name,
              'is_urgent': e.isUrgent,
              'is_registered': e.isRegistered,
              'image': e.imageUrl,
              'latitude': e.latitude,
              'longitude': e.longitude,
              'organizer_details': {
                'first_name': e.organizerName,
                'is_verified': e.organizerVerified,
                'rating': e.organizerRating,
              },
            })
        .toList();
  }
}
