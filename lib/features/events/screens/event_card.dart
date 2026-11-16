import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';

/// Reusable Event Card widget
class EventCard extends StatefulWidget {
  final VolunteerEvent event;
  final VoidCallback? onTap;
  final bool compact;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.compact = false,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isLiked = false;

  EventCategory get _category => appCategories.firstWhere(
      (c) => c.id == widget.event.categoryId,
      orElse: () => appCategories[0]);

  List<Color> get _gradientColors {
    return [_category.color, _category.color.withValues(alpha: 0.7)];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildImage(context),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: EventTypeBadge(type: widget.event.type),
                ),
                if (widget.event.isUrgent)
                  Positioned(
                    top: 12,
                    left: 90,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.priority_high_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 2),
                          Text(l10n.urgent,
                              style: GoogleFonts.inter(
                                  fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _isLiked = !_isLiked),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.small,
                      ),
                      child: Icon(
                        _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _isLiked ? AppColors.error : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (widget.event.distanceKm != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_walk_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(l10n.distanceKm(widget.event.distanceKm!.toStringAsFixed(1)),
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _openNgoProfile(context),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _category.bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_category.icon, color: _category.color, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.event.organizerName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.event.organizerVerified) const VerifiedBadge(),
                        if (widget.event.organizerRating > 0) ...[
                          const SizedBox(width: 6),
                          StarRating(
                            rating: widget.event.organizerRating,
                            showCount: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(widget.event.date),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.event.location,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.group_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.registeredCount(widget.event.spotsBooked),
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.hoursShort(widget.event.hours),
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HoursBadge(hours: widget.event.hours),
                      SpotsIndicator(event: widget.event),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) return DateFormat('d MMMM, HH:mm', l10n.localeName).format(date);
    if (diff.inHours < 1) return l10n.todayAt(DateFormat('HH:mm').format(date));
    if (diff.inDays == 0) return '${l10n.todayLabel}, ${DateFormat('HH:mm').format(date)}';
    if (diff.inDays == 1) return '${l10n.tomorrow}, ${DateFormat('HH:mm').format(date)}';
    return DateFormat('d MMMM, HH:mm', l10n.localeName).format(date);
  }

  Widget _buildImage(BuildContext context) {
    if (widget.event.imageUrl != null) {
      return Image.network(
        widget.event.imageUrl!,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const LoadingPlaceholder(height: 160);
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final assetPath = 'assets/images/${widget.event.categoryId}_cover.png';
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
          Center(
            child: Icon(_category.icon, color: Colors.white.withValues(alpha: 0.25), size: 60),
          ),
        ],
      ),
    );
  }

  void _openNgoProfile(BuildContext context) {
    if (widget.event.organizerId.isEmpty) return;
    Navigator.pushNamed(
      context,
      '/ngo-profile',
      arguments: <String, dynamic>{
        'organizationId': widget.event.organizerId,
        'initialName': widget.event.organizerName,
        'initialVerified': widget.event.organizerVerified,
        'initialRating': widget.event.organizerRating,
      },
    );
  }
}

class EventTypeBadge extends StatelessWidget {
  final EventType type;

  const EventTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOnline = type == EventType.online;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.accent : AppColors.info,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOnline ? l10n.online : l10n.offline,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SpotsIndicator extends StatelessWidget {
  final VolunteerEvent event;

  const SpotsIndicator({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasSpots = event.hasSpots;
    return Text(
      hasSpots ? l10n.spotsAvailable(event.spotsLeft) : l10n.noSpots,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: hasSpots ? AppColors.success : AppColors.error,
      ),
    );
  }
}

