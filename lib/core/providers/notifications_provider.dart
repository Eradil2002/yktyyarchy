import 'package:flutter/foundation.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/providers/mixins/error_handling_mixin.dart';
import '../services/notifications_service.dart';

class NotificationsProvider with ChangeNotifier, ErrorHandlingMixin {
  final NotificationsService _service;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationsProvider(this._service);

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => n.isRead == false).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.getNotifications();
    if (result['success']) {
      final data = result['data'];
      final raw = data is Map ? (data['results'] ?? <dynamic>[]) : data;
      _notifications = List<Map<String, dynamic>>.from(raw)
          .map(AppNotification.fromJson)
          .toList();
    } else {
      _error = mapError(Exception(result['error']?.toString() ?? 'Failed to load notifications'));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final success = await _service.markAsRead(id);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == id.toString());
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _service.markAllAsRead();
    if (success) {
      for (var n in _notifications) {
        n.isRead = true;
      }
      notifyListeners();
    }
  }
}
