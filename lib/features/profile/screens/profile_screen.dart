import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/l10n/app_localizations.dart';

part 'profile_widgets.dart';

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<UserReview> _reviews = [];
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfileData());
  }

  Future<void> _loadProfileData() async {
    try {
      final apiClient = ApiClient();
      final userResp = await apiClient.dio.get('users/me/');
      final userId = userResp.data['id'];

      // Load reviews
      List<UserReview> loadedReviews = [];
      try {
        final reviewsResp = await apiClient.dio.get('reviews/?target=$userId');
        final rawReviews = reviewsResp.data is List ? reviewsResp.data as List : [];
        loadedReviews = rawReviews
            .map((json) => UserReview.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } catch (_) {}

      // Load achievements
      List<Achievement> loadedAchievements = [];
      try {
        final achResp = await apiClient.dio.get('achievements/?user=$userId');
        final rawAch = achResp.data is List ? achResp.data as List : [];
        loadedAchievements = rawAch
            .map((json) => Achievement.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } catch (_) {
        // Achievements endpoint may not exist yet — compute from user data
        loadedAchievements = _computeAchievements(userResp.data);
      }

      if (mounted) {
        setState(() {
          _reviews = loadedReviews;
          _achievements = loadedAchievements;
        });
      }
    } catch (_) {
      // Silent: profile data not critical
    }
  }

  List<Achievement> _computeAchievements(dynamic userData) {
    final hours = ((userData['total_hours'] ?? 0) as num).toInt();
    final events = ((userData['events_count'] ?? 0) as num).toInt();
    return [
      Achievement(id: '1', title: 'Первый шаг', description: 'Участие в первом мероприятии',
        emoji: '🌱', isUnlocked: events >= 1, progress: events.clamp(0, 1), total: 1),
      Achievement(id: '2', title: 'Активист', description: 'Участие в 5 мероприятиях',
        emoji: '⭐', isUnlocked: events >= 5, progress: events.clamp(0, 5), total: 5),
      Achievement(id: '3', title: 'Герой', description: 'Участие в 20 мероприятиях',
        emoji: '🏆', isUnlocked: events >= 20, progress: events.clamp(0, 20), total: 20),
      Achievement(id: '4', title: '10 часов', description: 'Набрать 10 часов волонтёрства',
        emoji: '⏰', isUnlocked: hours >= 10, progress: hours.clamp(0, 10), total: 10),
      Achievement(id: '5', title: '50 часов', description: 'Набрать 50 часов волонтёрства',
        emoji: '🔥', isUnlocked: hours >= 50, progress: hours.clamp(0, 50), total: 50),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userData = authProvider.currentUser;

        if (userData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final reviews = _reviews;
        final achievements = _achievements;

        final isOrg = userData.isOrganizer;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: isOrg
                    ? _buildNgoHeader(context, userData, authProvider)
                    : _buildHeader(context, userData, authProvider),
              ),

              // Stats
              SliverToBoxAdapter(
                child: isOrg
                    ? _buildNgoStats(context, userData)
                    : _buildStats(context, userData),
              ),

              if (isOrg) ...[
                // NGO Description/Info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _NgoInfoCard(userData: userData),
                  ),
                ),
                // NGO Management
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _NgoManagementCard(l10n: l10n),
                  ),
                ),
              ] else ...[
                // Volunteer Book
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _VolunteerBookCard(userData: userData),
                  ),
                ),

                // Achievements preview
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _AchievementsCard(achievements: achievements),
                  ),
                ),
              ],

              // Recent reviews
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _ReviewsCard(reviews: reviews),
                ),
              ),

              // Menu sections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _MenuCard(
                    title: isOrg ? l10n.management : l10n.myActivity,
                    items: [
                      if (!isOrg) ...[
                        _MenuItem(
                          icon: Icons.event_available_rounded,
                          color: AppColors.primary,
                          title: l10n.myEvents,
                          subtitle: l10n.myEventsSubtitle,
                          onTap: () => Navigator.pushNamed(context, '/my-events'),
                        ),
                        _MenuItem(
                          icon: Icons.lightbulb_rounded,
                          color: AppColors.accent,
                          title: l10n.myInitiatives,
                          subtitle: l10n.myInitiativesSubtitle,
                          onTap: () => Navigator.pushNamed(context, '/my-initiatives'),
                        ),
                        _MenuItem(
                          icon: Icons.emoji_events_rounded,
                          color: Colors.amber,
                          title: l10n.achievements,
                          subtitle: l10n.achievementsReceived(achievements.where((a) => a.isUnlocked).length),
                          onTap: () => Navigator.pushNamed(context, '/achievements'),
                        ),
                      ] else ...[
                        _MenuItem(
                          icon: Icons.add_task_rounded,
                          color: AppColors.primary,
                          title: l10n.createEventTitle,
                          subtitle: l10n.createEventSubtitle,
                          onTap: () => Navigator.pushNamed(context, '/create-event'),
                        ),
                        _MenuItem(
                          icon: Icons.people_alt_rounded,
                          color: AppColors.info,
                          title: l10n.talentsMenu,
                          subtitle: l10n.talentRadarSubtitle,
                          onTap: () => Navigator.pushNamed(context, '/talents'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _MenuCard(
                    title: l10n.settings,
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        color: AppColors.info,
                        title: l10n.editProfile,
                        subtitle: l10n.editProfileSubtitle,
                        onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        color: AppColors.warning,
                        title: l10n.notifications,
                        subtitle: l10n.notificationsSubtitle,
                        onTap: () => Navigator.pushNamed(context, '/notification-settings'),
                      ),
                      _MenuItem(
                        icon: Icons.language_rounded,
                        color: AppColors.info,
                        title: l10n.language,
                        subtitle: switch (Localizations.localeOf(context).languageCode) {
                          'ky' => l10n.kyrgyz,
                          'en' => l10n.english,
                          _ => l10n.russian,
                        },
                        onTap: () => Navigator.pushNamed(context, '/language'),
                      ),
                    ],
                  ),
                ),
              ),

              // About section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _MenuCard(
                    title: l10n.aboutApp,
                    items: [
                      _MenuItem(
                        icon: Icons.privacy_tip_outlined,
                        color: AppColors.info,
                        title: l10n.privacyPolicyTitle,
                        subtitle: l10n.privacyPolicySubtitle,
                        onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                      ),
                      _MenuItem(
                        icon: Icons.description_outlined,
                        color: AppColors.info,
                        title: l10n.termsOfServiceTitle,
                        subtitle: l10n.termsOfServiceSubtitle,
                        onTap: () => Navigator.pushNamed(context, '/terms-of-service'),
                      ),
                    ],
                  ),
                ),
              ),

              // Logout button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: GestureDetector(
                    onTap: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.logout,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNgoHeader(BuildContext context, VolunteerUser userData, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    final orgName = userData.orgName;
    final location = userData.location.isNotEmpty ? userData.location : l10n.kyrgyzstan;
    final isVerified = userData.isVerified;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a237e), Color(0xFF311b92)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.ngoProfileTitle,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                ),
                child: Center(
                  child: userData.avatarUrl != null
                      ? ClipOval(child: Image.network(userData.avatarUrl!, fit: BoxFit.cover))
                      : Text(
                          orgName.isNotEmpty ? orgName[0].toUpperCase() : 'N',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      orgName,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.verified_rounded, color: AppColors.info, size: 22),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.ngo,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNgoStats(BuildContext context, VolunteerUser userData) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItemV2(
            l10n.ngoEventsListTitle,
            userData.eventsCount.toString(),
            Icons.event_rounded,
            const Color(0xFF667eea),
          ),
          _buildStatDividerV2(),
          _buildStatItemV2(
            l10n.talentRadarTitle,
            (userData.totalHours ~/ 10).toString(),
            Icons.people_alt_rounded,
            const Color(0xFF764ba2),
          ),
          _buildStatDividerV2(),
          _buildStatItemV2(
            l10n.rating,
            userData.rating.toStringAsFixed(1),
            Icons.star_rounded,
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDividerV2() {
    return Container(height: 40, width: 1, color: AppColors.divider);
  }

  Widget _buildStatItemV2(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.split(' ').first,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, VolunteerUser userData, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    final firstName = userData.firstName;
    final fullName = userData.name.trim();
    final username = userData.username;
    final location = userData.location.isNotEmpty ? userData.location : l10n.kyrgyzstan;
    final isVerified = userData.isVerified;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : l10n.appName[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fullName.isNotEmpty ? fullName : username,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 4),

              // Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, VolunteerUser userData) {
    final l10n = AppLocalizations.of(context)!;
    final totalHours = userData.totalHours;
    final rating = userData.rating;

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.medium,
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.schedule_rounded,
                value: totalHours.toString(),
                label: l10n.hours,
                color: AppColors.primary,
              ),
            ),
            Container(width: 1, height: 50, color: AppColors.divider),
            Expanded(
              child: _StatItem(
                icon: Icons.star_rounded,
                value: rating.toStringAsFixed(1),
                label: l10n.rating,
                color: Colors.amber,
              ),
            ),
            Container(width: 1, height: 50, color: AppColors.divider),
            Expanded(
              child: _StatItem(
                icon: Icons.emoji_events_rounded,
                value: '0',
                label: l10n.badges,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
