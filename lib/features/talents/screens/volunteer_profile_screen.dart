import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';
import 'package:volunteering/data/models/models.dart';

class VolunteerProfileScreen extends StatelessWidget {
  final VolunteerUser volunteer;

  const VolunteerProfileScreen({super.key, required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1a237e), Color(0xFF311b92)],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: const Icon(Icons.person_rounded, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              volunteer.name,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (volunteer.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: AppColors.info, size: 20),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats
                  Row(
                    children: [
                      _StatBox(
                        value: '${volunteer.totalHours}',
                        label: 'Часов',
                        icon: Icons.schedule_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        value: '${volunteer.eventsCount}',
                        label: 'Дел',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        value: volunteer.rating.toStringAsFixed(1),
                        label: 'Рейтинг',
                        icon: Icons.star_rounded,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Location
                  Text('Город', style: _labelStyle()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(volunteer.location, style: GoogleFonts.inter(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Skills
                  if (volunteer.skills.isNotEmpty) ...[
                    Text('Навыки', style: _labelStyle()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: volunteer.skills.map((s) => TagChip(label: s)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Badges
                  Text('Бейджи (${volunteer.badgesCount})', style: _labelStyle()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CompactBadge(icon: Icons.local_fire_department_rounded, color: Colors.orange, label: 'Активный'),
                      const SizedBox(width: 12),
                      _CompactBadge(icon: Icons.volunteer_activism_rounded, color: AppColors.primary, label: 'Помощник'),
                      if (volunteer.totalHours > 50) ...[
                        const SizedBox(width: 12),
                        _CompactBadge(icon: Icons.workspace_premium_rounded, color: const Color(0xFFFFD700), label: 'Ветеран'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About (mock text)
                  Text('О себе', style: _labelStyle()),
                  const SizedBox(height: 8),
                  Text(
                    'Активный волонтер, готов помогать в выходные дни. Особенно интересуют социальные проекты и экология.',
                    style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              AppSnackbar.showSuccess(context, 'Приглашение отправлено!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF311b92),
              minimumSize: const Size(double.infinity, 52),
            ),
            child: const Text('Пригласить в проект'),
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CompactBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _CompactBadge({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
