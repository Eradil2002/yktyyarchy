import 'package:flutter/foundation.dart';
import 'package:volunteering/core/providers/mixins/error_handling_mixin.dart';
import 'package:volunteering/data/models/models.dart';
import '../services/initiatives_service.dart';
import '../services/offline_cache_service.dart';

class InitiativesProvider with ChangeNotifier, ErrorHandlingMixin {
  final InitiativesService _initiativesService;
  final OfflineCacheService _offlineCacheService = OfflineCacheService();

  List<Initiative> _initiatives = <Initiative>[];
  bool _isLoading = false;
  String? _error;
  bool _loadedFromCache = false;

  InitiativesProvider(this._initiativesService);

  List<Initiative> get initiatives => _initiatives;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get loadedFromCache => _loadedFromCache;

  Future<void> loadMyInitiatives() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final cached = await _offlineCacheService.loadMyInitiatives();
    if (cached.isNotEmpty) {
      _initiatives = cached.map(Initiative.fromJson).toList();
      _loadedFromCache = true;
      _isLoading = false;
      notifyListeners();
    }

    try {
      _initiatives = await _initiativesService.getMyInitiativesTyped();
      _loadedFromCache = false;
      await _offlineCacheService.saveMyInitiatives(
        _initiatives
            .map((i) => <String, dynamic>{
                  'id': i.id,
                  'title': i.title,
                  'description': i.description,
                  'creator': i.authorId,
                  'creator_name': i.authorName,
                  'category': i.categoryId,
                  'location': i.location,
                  'date': i.date.toIso8601String(),
                  'hours': i.hours,
                  'before_photos': i.beforePhotos,
                  'after_photos': i.afterPhotos,
                  'is_approved': i.isApproved,
                  'status': i.status,
                })
            .toList(),
      );
    } catch (e) {
      _error = mapError(e, fallback: 'Failed to load initiatives');
    }

    _isLoading = false;
    notifyListeners();
  }
}
