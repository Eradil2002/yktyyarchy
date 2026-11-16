part of 'home_screen.dart';

class _EventCard extends StatelessWidget {
  final VolunteerEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = event.title.isEmpty ? l10n.noTitle : event.title;
    final location = event.location.isEmpty ? l10n.notSpecified : event.location;
    final participantsCount = event.spotsBooked;
    final maxParticipants = event.spotsTotal;
    final isUrgent = event.isUrgent;
    final category = event.categoryId;
    final eventDate = event.date;

    final categoryInfo = appCategories.firstWhere(
      (cat) => cat.id == category,
      orElse: () => appCategories.first,
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/event-detail',
          arguments: event,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryInfo.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(categoryInfo.icon, size: 14, color: categoryInfo.color),
                        const SizedBox(width: 4),
                        Text(
                          localizedCategoryLabel(context, categoryInfo),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: categoryInfo.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text(
                            l10n.urgent,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(eventDate, l10n),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        l10n.participantsOf(participantsCount, maxParticipants),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxParticipants > 0 ? participantsCount / maxParticipants : 0,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(categoryInfo.color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) {
      return '${l10n.todayLabel}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (eventDay == tomorrow) {
      return '${l10n.tomorrow}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return DateFormat('d MMM, HH:mm', l10n.localeName).format(date);
  }
}
