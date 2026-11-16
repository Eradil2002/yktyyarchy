import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/l10n/app_localizations.dart';

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
