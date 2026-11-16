import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/providers/events_provider.dart';
import 'package:volunteering/core/services/user_lists_service.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/core/utils/debug_i18n_logger.dart';

part 'home_header_section.dart';
part 'home_event_card.dart';
part 'home_filters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Filter state
  String? _filterType;
  bool _filterUrgentOnly = false;
  bool _filterToday = false;
  bool _filterNearby = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollNearEnd);
    // Load events when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  void _onScrollNearEnd() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) return;
    if (pos.pixels < pos.maxScrollExtent - 480) return;
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    eventsProvider.loadMoreEvents();
  }

  Future<void> _loadEvents() async {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    
    double? lat;
    double? lng;

    if (_filterNearby) {
      try {
        final position = await _getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
        setState(() => _filterNearby = false);
      }
    }

    eventsProvider.loadEvents(
      category: _selectedCategory,
      type: _filterType,
      isUrgent: _filterUrgentOnly,
      date: _filterToday ? 'today' : null,
      lat: lat,
      lng: lng,
    );
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Службы геолокации отключены.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Разрешение на геолокацию отклонено.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Разрешение на геолокацию отклонено навсегда.';
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollNearEnd);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // #region agent log
    logI18nDebug(
      runId: 'baseline',
      hypothesisId: 'H2',
      location: 'home_screen.dart:build',
      message: 'Home screen localization snapshot',
      data: {
        'locale': Localizations.localeOf(context).languageCode,
        'l10nCategoryEcology': l10n.categoryEcology,
        'staticCategory0': appCategories.isNotEmpty ? appCategories.first.label : 'none',
      },
    );
    // #endregion

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer3<AuthProvider, EventsProvider, UserListsService>(
        builder: (context, authProvider, eventsProvider, lists, _) {
          final userData = authProvider.currentUser;
          final events = eventsProvider.events;
          final isLoading = eventsProvider.isLoading;
          final error = eventsProvider.error;

          // Filter events by search query
          final filteredEvents = events.where((event) {
            if (_searchQuery.isEmpty) return true;
            final title = event.title.toLowerCase();
            final location = event.location.toLowerCase();
            final query = _searchQuery.toLowerCase();
            return title.contains(query) || location.contains(query);
          }).toList();

          final showSkeleton =
              isLoading && filteredEvents.isEmpty && !eventsProvider.loadedFromCache;
          final showList = filteredEvents.isNotEmpty &&
              !(isLoading && filteredEvents.isEmpty && !eventsProvider.loadedFromCache);

          VolunteerEvent? eventById(String id) {
            for (final e in events) {
              if (e.id == id) return e;
            }
            return null;
          }

          final recentResolved = <VolunteerEvent>[];
          for (final id in lists.recentIds) {
            final e = eventById(id);
            if (e != null) recentResolved.add(e);
            if (recentResolved.length >= 10) break;
          }

          return RefreshIndicator(
            onRefresh: _loadEvents,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(userData, l10n)),
                SliverToBoxAdapter(child: _buildQuickFilters(l10n)),

                if (recentResolved.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            l10n.recentlyViewed,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 360,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: recentResolved.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) => SizedBox(
                              width: 320,
                              child: _EventCard(event: recentResolved[index]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (eventsProvider.loadedFromCache)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'Офлайн режим: показываем сохранённые события',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                SliverToBoxAdapter(child: _buildCategories(l10n)),

                if (showSkeleton)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Skeletonizer(
                            child: Container(
                              height: 132,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider),
                              ),
                            ),
                          ),
                        ),
                        childCount: 6,
                      ),
                    ),
                  ),

                if (error != null && !isLoading && filteredEvents.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: l10n.loadingError(error),
                      subtitle: error,
                      action: GestureDetector(
                        onTap: _loadEvents,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.retry,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (filteredEvents.isEmpty && !isLoading && error == null && !showSkeleton)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: l10n.noEventsFound,
                      subtitle: l10n.noEventsSubtitle,
                    ),
                  ),

                if (showList)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = filteredEvents[index];
                          return _EventCard(event: event);
                        },
                        childCount: filteredEvents.length,
                      ),
                    ),
                  ),

                if (showList && eventsProvider.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 100),
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLocationPicker() {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final regions = [
      'Бишкек',
      'Ош',
      'Чуйская область',
      'Ошская область',
      'Джалал-Абадская область',
      'Иссык-Кульская область',
      'Нарынская область',
      'Таласская область',
      'Баткенская область',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.locationLabel,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: regions.length,
                itemBuilder: (sheetContext, index) {
                  final region = regions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: const Icon(Icons.location_city_rounded, color: AppColors.primary),
                    title: Text(
                      region,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    onTap: () async {
                      final success = await authProvider.updateProfile(location: region);
                      if (!sheetContext.mounted) return;
                      if (success) {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(content: Text(l10n.profileUpdatedSuccess)),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
