import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/l10n/app_localizations.dart';

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
                        subtitle: Localizations.localeOf(context).languageCode == 'ky'
                            ? l10n.kyrgyz
                            : l10n.russian,
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NgoInfoCard extends StatelessWidget {
  final VolunteerUser userData;

  const _NgoInfoCard({required this.userData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final description = userData.orgDescription;
    final email = userData.orgEmail;
    final website = userData.orgWebsite;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aboutApp, // Proxy for "About Organization"
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description.isNotEmpty ? description : l10n.ngoNoDescription,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (email.isNotEmpty || website.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            if (email.isNotEmpty)
              _buildContactItem(Icons.email_outlined, email),
            if (website.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildContactItem(Icons.language_rounded, website),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _NgoManagementCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _NgoManagementCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard_customize_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.management,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context,
                  l10n.createEventTitle,
                  Icons.add_circle_outline_rounded,
                  () => Navigator.pushNamed(context, '/create-event'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  context,
                  l10n.myEvents,
                  Icons.list_alt_rounded,
                  () => Navigator.pushNamed(context, '/my-events'), // Assume this exists or created
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VolunteerBookCard extends StatelessWidget {
  final VolunteerUser userData;

  const _VolunteerBookCard({required this.userData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalHours = userData.totalHours;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/volunteer-book'),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.primaryGlow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.volunteerBook,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.confirmedHours(totalHours),
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.open,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _AchievementsCard extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsCard({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unlocked = achievements.where((a) => a.isUnlocked).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.achievements,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/achievements'),
                child: Text(l10n.allAchievements,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: achievements.take(5).map((a) {
              return _AchievementBadge(achievement: a);
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.achievementsCount(unlocked.length, achievements.length),
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: achievement.isUnlocked ? AppColors.accent.withValues(alpha: 0.1) : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: achievement.isUnlocked ? AppColors.accent : AppColors.divider,
                width: 2,
              ),
            ),
            child: Center(
              child: achievement.iconPath != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        achievement.iconPath!,
                        color: achievement.isUnlocked ? null : Colors.grey.withValues(alpha: 0.5),
                        colorBlendMode: achievement.isUnlocked ? null : BlendMode.modulate,
                      ),
                    )
                  : Text(
                      achievement.emoji ?? '🏆',
                      style: TextStyle(
                        fontSize: 22,
                        color: achievement.isUnlocked ? null : const Color(0x44000000),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: achievement.isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: achievement.isUnlocked ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  final List<UserReview> reviews;

  const _ReviewsCard({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.reviewsFromOrganizations,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/reviews'),
                child: Text(l10n.allReviews,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reviews.take(2).map((r) => _ReviewItem(review: r)),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final UserReview review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    Row(
                      children: List.generate(5, (i) => Icon(
                            i < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.accent,
                            size: 14,
                          )),
                    ),
                  ],
                ),
              ),
              Text(
                _timeAgo(context, review.date),
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.activityLabel}: ${review.eventTitle}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _timeAgo(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return l10n.monthsAgo((diff.inDays / 30).round());
    if (diff.inDays > 0) return l10n.daysAgo(diff.inDays);
    return l10n.todayLabel;
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  if (item.subtitle.isNotEmpty)
                    Text(item.subtitle,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
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

class _MenuItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

// ============================================================
// ACHIEVEMENTS SCREEN
// ============================================================

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      final apiClient = ApiClient();
      final userResp = await apiClient.dio.get('users/me/');
      final userId = userResp.data['id'];

      try {
        final achResp = await apiClient.dio.get('achievements/?user=$userId');
        final rawAch = achResp.data is List ? achResp.data as List : [];
        if (mounted) {
          setState(() {
            _achievements = rawAch
                .map((json) => Achievement.fromJson(Map<String, dynamic>.from(json)))
                .toList();
            _isLoading = false;
          });
        }
        return;
      } catch (_) {}

      // Fallback: compute from user data
      final hours = ((userResp.data['total_hours'] ?? 0) as num).toInt();
      final events = ((userResp.data['events_count'] ?? 0) as num).toInt();
      if (mounted) {
        setState(() {
          _achievements = [
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
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final achievements = _achievements;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievements)),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: achievements.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _AchievementCard(achievement: achievement);
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unlocked = achievement.isUnlocked;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? AppColors.accent.withValues(alpha: 0.4) : AppColors.divider,
          width: unlocked ? 2 : 1,
        ),
        boxShadow: unlocked ? AppShadows.small : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          achievement.iconPath != null
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      achievement.iconPath!,
                      color: unlocked ? null : Colors.grey.withValues(alpha: 0.5),
                      colorBlendMode: unlocked ? null : BlendMode.modulate,
                    ),
                  ),
                )
              : Text(
                  achievement.emoji ?? '🏆',
                  style: TextStyle(fontSize: 40, color: unlocked ? null : const Color(0x44000000)),
                ),
          const SizedBox(height: 10),
          Text(
            achievement.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Progress
          if (!unlocked) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.progress / achievement.total,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${achievement.progress}/${achievement.total}',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.received,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
              ),
            ),
        ],
      ),
    );
  }
}
