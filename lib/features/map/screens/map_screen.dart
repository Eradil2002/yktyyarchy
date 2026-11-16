import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/providers/events_provider.dart';
import 'package:volunteering/l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedCategory;
  VolunteerEvent? _selectedEvent;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _filterUrgentOnly = false;
  bool _filterToday = false;
  bool _filterNearby = false;

  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = false;

  // Default to Bishkek
  final LatLng _defaultLocation = const LatLng(42.8746, 74.5698);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
      _determinePosition();
    });
  }

  Future<void> _loadEvents() async {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    double? lat;
    double? lng;

    if (_filterNearby) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw 'Службы геолокации отключены.';
        }
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw 'Разрешение на геолокацию отклонено.';
          }
        }
        if (permission == LocationPermission.deniedForever) {
          throw 'Разрешение на геолокацию отклонено навсегда.';
        }
        final position = await Geolocator.getCurrentPosition();
        lat = position.latitude;
        lng = position.longitude;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
        setState(() => _filterNearby = false);
      }
    }

    await eventsProvider.loadEvents(
      category: _selectedCategory,
      isUrgent: _filterUrgentOnly,
      date: _filterToday ? 'today' : null,
      lat: lat,
      lng: lng,
    );
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoadingLocation = true);
    
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        _mapController.move(_currentPosition!, 14.0);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _centerOnUser() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 14.0);
    } else {
      _determinePosition();
    }
  }

  List<VolunteerEvent> _filterEvents(List<VolunteerEvent> events) {
    return events.where((e) {
      if (_selectedCategory != null && e.categoryId != _selectedCategory) return false;
      if (e.latitude == null || e.longitude == null) return false;
      if (_searchQuery.isEmpty) return true;
      final title = e.title.toLowerCase();
      final location = e.location.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || location.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildMapBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 8),
                _buildCategoryFilterChips(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMapQuickFilters(l10n),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 140,
            left: 16,
            child: _buildEventCounter(),
          ),

          Positioned(
            right: 16,
            bottom: 160,
            child: _buildMapControls(),
          ),

          if (_selectedEvent != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildEventPopup(_selectedEvent!),
            ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, _) {
        final events = eventsProvider.events;
        final filteredEvents = _filterEvents(events);

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultLocation,
            initialZoom: 12.0,
            onTap: (_, __) {
              if (_selectedEvent != null) {
                setState(() => _selectedEvent = null);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'kg.volunteers.app',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                if (_currentPosition != null)
                  Marker(
                    point: _currentPosition!,
                    width: 44,
                    height: 44,
                    child: _buildUserLocationMarker(),
                  ),
                ...filteredEvents.map((e) {
                  final lat = e.latitude!;
                  final lng = e.longitude!;
                  final catId = e.categoryId;
                  final category = appCategories.firstWhere(
                    (c) => c.id == catId, 
                    orElse: () => appCategories.first
                  );
                  
                  final isSelected = _selectedEvent != null && _selectedEvent!.id == e.id;

                  return Marker(
                    point: LatLng(lat, lng),
                    width: isSelected ? 50 : 40,
                    height: isSelected ? 50 : 40,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEvent = e;
                        });
                        _mapController.move(LatLng(lat, lng), _mapController.camera.zoom);
                      },
                      child: _MapPin(
                        category: category,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserLocationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: AppShadows.small,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.medium,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(fontSize: 15),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: l10n.searchOnMapPlaceholder,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _loadEvents(),
              tooltip: l10n.retry,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapQuickFilters(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _MapCompactFilterChip(
            icon: Icons.location_on_rounded,
            label: l10n.nearby,
            color: const Color(0xFF667eea),
            isActive: _filterNearby,
            onTap: () {
              setState(() => _filterNearby = !_filterNearby);
              _loadEvents();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MapCompactFilterChip(
            icon: Icons.today_rounded,
            label: l10n.today,
            color: AppColors.primary,
            isActive: _filterToday,
            onTap: () {
              setState(() {
                _filterToday = !_filterToday;
                if (_filterToday) {
                  _filterUrgentOnly = false;
                  _filterNearby = false;
                }
                _selectedCategory = null;
              });
              _loadEvents();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MapCompactFilterChip(
            icon: Icons.local_fire_department_rounded,
            label: l10n.urgent,
            color: AppColors.error,
            isActive: _filterUrgentOnly,
            onTap: () {
              setState(() {
                _filterUrgentOnly = !_filterUrgentOnly;
                if (_filterUrgentOnly) {
                  _filterToday = false;
                  _filterNearby = false;
                }
              });
              _loadEvents();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterChips() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: l10n.all,
            isSelected: _selectedCategory == null,
            color: AppColors.primary,
            onTap: () {
              setState(() => _selectedCategory = null);
              _loadEvents();
            },
          ),
          ...appCategories.map((cat) => _FilterChip(
                label: localizedCategoryLabel(context, cat),
                icon: cat.icon,
                isSelected: _selectedCategory == cat.id,
                color: cat.color,
                onTap: () {
                  setState(() {
                    _selectedCategory = _selectedCategory == cat.id ? null : cat.id;
                  });
                  _loadEvents();
                },
              )),
        ],
      ),
    );
  }

  Widget _buildEventCounter() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, _) {
        final eventsCount = _filterEvents(eventsProvider.events).length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.medium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onMapCount(eventsCount),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              if (_isLoadingLocation)
                Text(
                  l10n.findingYou,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
                ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        _MapControlBtn(
          icon: Icons.my_location_rounded, 
          onTap: _centerOnUser,
        ),
        const SizedBox(height: 8),
        _MapControlBtn(
          icon: Icons.add_rounded,
          onTap: () {
            final zoom = (_mapController.camera.zoom + 1).clamp(3.0, 19.0);
            _mapController.move(_mapController.camera.center, zoom);
          },
        ),
        const SizedBox(height: 8),
        _MapControlBtn(
          icon: Icons.remove_rounded,
          onTap: () {
            final zoom = (_mapController.camera.zoom - 1).clamp(3.0, 19.0);
            _mapController.move(_mapController.camera.center, zoom);
          },
        ),
      ],
    );
  }

  Widget _buildEventPopup(VolunteerEvent eventData) {
    final l10n = AppLocalizations.of(context)!;
    final title = eventData.title.isEmpty ? l10n.eventFallbackTitle : eventData.title;
    final location = eventData.location;
    final spotsTotal = eventData.spotsTotal;
    final spotsBooked = eventData.spotsBooked;
    final hasSpots = spotsBooked < spotsTotal;
    
    final catId = eventData.categoryId;
    final category = appCategories.firstWhere(
      (c) => c.id == catId, 
      orElse: () => appCategories.first
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/event-detail',
          arguments: eventData,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.large,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(category.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        hasSpots ? l10n.spotsAvailable(spotsTotal - spotsBooked) : l10n.noSpots,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: hasSpots ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final EventCategory category;
  final bool isSelected;

  const _MapPin({required this.category, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Container(
            width: isSelected ? 44 : 36,
            height: isSelected ? 44 : 36,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: category.color.withValues(alpha: 0.6),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Icon(category.icon, color: Colors.white, size: isSelected ? 22 : 18),
          ),
          CustomPaint(
            size: const Size(10, 8),
            painter: _PinTailPainter(color: category.color),
          ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.divider),
          boxShadow: isSelected ? AppShadows.small : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isSelected ? Colors.white : color, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.medium,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _MapCompactFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const _MapCompactFilterChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: isActive ? 1.0 : 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.white : color, size: 16),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isActive ? Colors.white : color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
