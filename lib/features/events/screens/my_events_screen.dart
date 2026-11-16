import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/core/services/offline_cache_service.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/features/notifications/screens/notifications_widgets.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OfflineCacheService _offlineCacheService = OfflineCacheService();
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _fatalLoadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      final isOrg = user?.isOrganizer == true;
      final apiClient = ApiClient();

      if (isOrg) {
        final response = await apiClient.dio.get('events/', queryParameters: {'organizer': user?.id});
        final rawData = response.data;
        List<Map<String, dynamic>> events = [];
        if (rawData is Map && rawData.containsKey('results')) {
          events = List<Map<String, dynamic>>.from(rawData['results']);
        } else if (rawData is List) {
          events = List<Map<String, dynamic>>.from(rawData);
        }
        // Transform NGO events to matching structure for UI if needed or handle in ListView
        // For simplicity, we'll wrap them like registrations so the rest of the code works
        final wrappedEvents = events.map((e) => {'event': e}).toList();

        if (mounted) {
          setState(() {
            _events = wrappedEvents;
            _isLoading = false;
            _fatalLoadError = null;
          });
        }
      } else {
        final response = await apiClient.dio.get('events/my-registrations/');
        final events = List<Map<String, dynamic>>.from(response.data);
        await _offlineCacheService.saveMyRegistrations(events);
        if (mounted) {
          setState(() {
            _events = events;
            _isLoading = false;
            _fatalLoadError = null;
          });
        }
      }
    } catch (e) {
      final cachedEvents = await _offlineCacheService.loadMyRegistrations();
      if (!mounted) return;
      setState(() {
        _events = cachedEvents;
        _isLoading = false;
        _fatalLoadError = cachedEvents.isEmpty ? '$e' : null;
      });
      if (cachedEvents.isNotEmpty) {
        final updatedAt = await _offlineCacheService.loadMyRegistrationsUpdatedAt();
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        final suffix = updatedAt == null ? '' : ' ${l10n.cachedDataFrom(updatedAt.day, updatedAt.month, updatedAt.year)}';
        AppSnackbar.showError(context, '${l10n.offlineScheduleLoaded}$suffix');
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      AppSnackbar.showError(context, l10n.loadingError('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myEvents)),
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_events.isEmpty && _fatalLoadError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.myEvents),
          actions: [
            IconButton(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        body: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: l10n.loadingError(_fatalLoadError!),
          subtitle: _fatalLoadError,
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
      );
    }

    final now = DateTime.now();
    final upcoming = _events.where((e) {
      try {
        final date = DateTime.parse(e['event']?['date'] ?? '');
        return date.isAfter(now);
      } catch (_) {
        return false;
      }
    }).toList();
    final past = _events.where((e) {
      try {
        final date = DateTime.parse(e['event']?['date'] ?? '');
        return date.isBefore(now);
      } catch (_) {
        return false;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myEvents),
        actions: [
          IconButton(
            onPressed: _loadEvents,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: l10n.upcoming),
            Tab(text: l10n.past),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: TabBarView(
        controller: _tabController,
        children: [
          EventsList(events: upcoming),
          EventsList(events: past, completed: true),
        ],
      ),
    );
  }
}

