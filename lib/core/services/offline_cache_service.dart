import 'package:hive_flutter/hive_flutter.dart';

class OfflineCacheService {
  static const String _boxName = 'offline_cache_box';
  static const String _myProfileKey = 'my_profile_v1';
  static const String _myProfileUpdatedAtKey = 'my_profile_updated_at_v1';
  static const String _myRegistrationsKey = 'my_registrations_schedule_v1';
  static const String _myRegistrationsUpdatedAtKey =
      'my_registrations_schedule_updated_at_v1';
  static const String _eventsFeedKey = 'events_feed_v1';
  static const String _eventsFeedUpdatedAtKey = 'events_feed_updated_at_v1';
  static const String _myInitiativesKey = 'my_initiatives_v1';
  static const String _myInitiativesUpdatedAtKey = 'my_initiatives_updated_at_v1';

  Future<void> saveMyRegistrations(List<Map<String, dynamic>> items) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_myRegistrationsKey, items);
    await box.put(
      _myRegistrationsUpdatedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> saveMyProfile(Map<String, dynamic> profile) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_myProfileKey, profile);
    await box.put(_myProfileUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, dynamic>?> loadMyProfile() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_myProfileKey);
    if (raw is! Map) return null;
    return Map<String, dynamic>.from(raw);
  }

  Future<DateTime?> loadMyProfileUpdatedAt() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_myProfileUpdatedAtKey);
    if (raw is! int) return null;
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  Future<List<Map<String, dynamic>>> loadMyRegistrations() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_myRegistrationsKey);
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<DateTime?> loadMyRegistrationsUpdatedAt() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_myRegistrationsUpdatedAtKey);
    if (raw is! int) return null;
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  Future<void> saveEventsFeed(List<dynamic> items) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_eventsFeedKey, items);
    await box.put(_eventsFeedUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<dynamic>> loadEventsFeed() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_eventsFeedKey);
    if (raw is! List) return <dynamic>[];
    return List<dynamic>.from(raw);
  }

  Future<void> saveMyInitiatives(List<Map<String, dynamic>> items) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_myInitiativesKey, items);
    await box.put(
      _myInitiativesUpdatedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<Map<String, dynamic>>> loadMyInitiatives() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_myInitiativesKey);
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
