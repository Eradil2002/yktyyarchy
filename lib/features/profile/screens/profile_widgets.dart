part of 'profile_screen.dart';

// ============================================================
// PROFILE SCREEN — private card widgets
// ============================================================

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
