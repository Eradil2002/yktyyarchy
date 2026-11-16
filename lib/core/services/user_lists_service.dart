import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local favorites (event ids) and recently viewed event ids (Hive box `user_lists`).
/// Box must be opened before use ([Hive.openBox] in main).
class UserListsService extends ChangeNotifier {
  Box<dynamic> get _b => Hive.box<dynamic>('user_lists');

  List<String> get favoriteIds {
    final raw = _b.get(_favoritesKey);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }

  List<String> get recentIds {
    final raw = _b.get(_recentKey);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }

  bool isFavorite(String eventId) => favoriteIds.contains(eventId);

  Future<void> toggleFavorite(String eventId) async {
    final ids = List<String>.from(favoriteIds);
    if (ids.contains(eventId)) {
      ids.remove(eventId);
    } else {
      ids.add(eventId);
    }
    await _b.put(_favoritesKey, ids);
    notifyListeners();
  }

  Future<void> recordEventView(String eventId) async {
    final ids = List<String>.from(recentIds);
    ids.remove(eventId);
    ids.insert(0, eventId);
    const maxItems = 15;
    if (ids.length > maxItems) {
      ids.removeRange(maxItems, ids.length);
    }
    await _b.put(_recentKey, ids);
    notifyListeners();
  }

  static const _favoritesKey = 'favorite_event_ids';
  static const _recentKey = 'recent_event_ids';
}

