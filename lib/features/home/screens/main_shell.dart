import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/features/home/screens/home_screen.dart';
import 'package:volunteering/features/map/screens/map_screen.dart';
import 'package:volunteering/features/profile/screens/profile_screen.dart';
import 'package:volunteering/features/talents/screens/talents_screen.dart';
import 'package:volunteering/features/onboarding/onboarding_screen.dart';
import 'package:volunteering/l10n/app_localizations.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late int _currentIndex;
  final ApiClient _apiClient = ApiClient();
  bool _reviewPromptShown = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndPromptPendingReviews();
      if (!mounted) return;
      await _maybeShowOnboarding();
    });
  }

  Future<void> _maybeShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('onboarding_done') == true) return;
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    SizedBox(), // placeholder for FAB action
    TalentsScreen(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      _showCreateBottomSheet();
      return;
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _checkAndPromptPendingReviews() async {
    if (!mounted || _reviewPromptShown) return;

    try {
      final meResponse = await _apiClient.dio.get('users/me/');
      final currentUser = Map<String, dynamic>.from(meResponse.data);
      final currentUserId = currentUser['id'];
      if (currentUserId == null) return;

      final pending = <_PendingReview>[];
      pending.addAll(await _collectVolunteerSidePendingReviews(currentUserId as int));
      pending.addAll(await _collectNgoSidePendingReviews(currentUserId));

      if (!mounted || pending.isEmpty) return;

      _reviewPromptShown = true;
      await _showAutoReviewPrompt(pending.first);
    } catch (_) {
      // Silent fail: review prompt must never block app start.
    }
  }

  Future<List<_PendingReview>> _collectVolunteerSidePendingReviews(int currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final registrationsResp = await _apiClient.dio.get('events/my-registrations/');
    final registrations = List<Map<String, dynamic>>.from(registrationsResp.data);
    final now = DateTime.now();
    final result = <_PendingReview>[];

    for (final reg in registrations) {
      final event = Map<String, dynamic>.from(reg['event'] ?? <String, dynamic>{});
      final status = (reg['status'] ?? '').toString();
      if (status != 'attended') continue;

      final targetUser = event['organizer'];
      final eventId = event['id'];
      final title = (event['title'] ?? '').toString();
      final dateRaw = (event['date'] ?? '').toString();
      if (targetUser == null || eventId == null || title.isEmpty || dateRaw.isEmpty) continue;

      final eventDate = DateTime.tryParse(dateRaw);
      if (eventDate == null) continue;
      if (now.isBefore(eventDate.add(const Duration(days: 1)))) continue;

      final reviewKey = 'review_done_${eventId}_$targetUser';
      if (prefs.getBool(reviewKey) == true) continue;

      result.add(
        _PendingReview(
          eventId: eventId.toString(),
          eventTitle: title,
          targetUserId: targetUser,
          targetName: (event['organizer_details']?['first_name'] ?? '').toString(),
        ),
      );
    }
    return result;
  }

  Future<List<_PendingReview>> _collectNgoSidePendingReviews(int currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsResp = await _apiClient.dio.get('events/');
    final events = List<Map<String, dynamic>>.from(eventsResp.data);
    final now = DateTime.now();
    final result = <_PendingReview>[];

    for (final event in events) {
      if (event['organizer'] != currentUserId) continue;
      final dateRaw = (event['date'] ?? '').toString();
      final eventDate = DateTime.tryParse(dateRaw);
      if (eventDate == null) continue;
      if (now.isBefore(eventDate.add(const Duration(days: 1)))) continue;

      final eventId = event['id'];
      if (eventId == null) continue;

      try {
        final participantsResp = await _apiClient.dio.get('events/$eventId/registrations/');
        final participants = List<Map<String, dynamic>>.from(participantsResp.data);
        for (final item in participants) {
          final status = (item['status'] ?? '').toString();
          if (status != 'attended') continue;

          final targetUser = item['volunteer'] ?? item['user'];
          if (targetUser == null) continue;

          final reviewKey = 'review_done_${eventId}_$targetUser';
          if (prefs.getBool(reviewKey) == true) continue;

          result.add(
            _PendingReview(
              eventId: eventId.toString(),
              eventTitle: (event['title'] ?? '').toString(),
              targetUserId: targetUser,
              targetName: (item['volunteer_details']?['first_name'] ?? '').toString(),
            ),
          );
        }
      } catch (_) {
        // Endpoint may be unavailable in some environments.
      }
    }
    return result;
  }

  Future<void> _showAutoReviewPrompt(_PendingReview review) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text(l10n.leaveReviewTitle),
        content: Text(l10n.rateEvent(review.eventTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _AutoReviewBottomSheet(
                  pendingReview: review,
                  apiClient: _apiClient,
                ),
              );
            },
            child: Text(l10n.leaveReviewTitle),
          ),
        ],
      ),
    );
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => _CreateBottomSheet(
        onCreateEvent: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/create-event');
        },
        onCreateInitiative: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/create-initiative');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navItems = [
      _NavItem(icon: Icons.home_rounded, activeIcon: Icons.home_rounded, label: l10n.homeMenu),
      _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: l10n.mapMenu),
      const _NavItem(icon: Icons.add, activeIcon: Icons.add, label: ''),
      _NavItem(icon: Icons.star_outline_rounded, activeIcon: Icons.star_rounded, label: l10n.talentsMenu),
      _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: l10n.profileMenu),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNav(navItems),
      ),
    );
  }

  Widget _buildBottomNav(List<_NavItem> navItems) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isActive = _currentIndex == index;

              if (index == 2) {
                // FAB-style center button
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onNavTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.primaryGlow,
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onNavTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? AppColors.primary : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isActive ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                          child: Text(item.label),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: isActive ? 20 : 0,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PendingReview {
  final String eventId;
  final String eventTitle;
  final int targetUserId;
  final String targetName;

  const _PendingReview({
    required this.eventId,
    required this.eventTitle,
    required this.targetUserId,
    required this.targetName,
  });
}

class _AutoReviewBottomSheet extends StatefulWidget {
  final _PendingReview pendingReview;
  final ApiClient apiClient;

  const _AutoReviewBottomSheet({
    required this.pendingReview,
    required this.apiClient,
  });

  @override
  State<_AutoReviewBottomSheet> createState() => _AutoReviewBottomSheetState();
}

class _AutoReviewBottomSheetState extends State<_AutoReviewBottomSheet> {
  int _rating = 0;
  bool _isSubmitting = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_rating == 0) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.apiClient.dio.post(
        '/reviews/',
        data: {
          'target_user': widget.pendingReview.targetUserId,
          'rating': _rating,
          'comment': _commentController.text.trim(),
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        'review_done_${widget.pendingReview.eventId}_${widget.pendingReview.targetUserId}',
        true,
      );

      if (!mounted) return;
      Navigator.pop(context);
      AppSnackbar.showSuccess(context, l10n.thankYouForReview);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.showError(context, l10n.error('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.leaveReviewTitle,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.rateEvent(widget.pendingReview.eventTitle),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.accent,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.shareImpression,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.send),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ============================================================
// CREATE BOTTOM SHEET
// ============================================================

class _CreateBottomSheet extends StatelessWidget {
  final VoidCallback onCreateEvent;
  final VoidCallback onCreateInitiative;

  const _CreateBottomSheet({
    required this.onCreateEvent,
    required this.onCreateInitiative,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              l10n.createWhatTitle,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createWhatSubtitle,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Create event option
            _CreateOption(
              icon: Icons.event_rounded,
              title: l10n.createEventTitle,
              subtitle: l10n.createEventSubtitle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              onTap: onCreateEvent,
            ),
            const SizedBox(height: 14),

            // Create initiative
            _CreateOption(
              icon: Icons.volunteer_activism_rounded,
              title: l10n.createInitiativeTitle,
              subtitle: l10n.createInitiativeSubtitle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              onTap: onCreateInitiative,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
