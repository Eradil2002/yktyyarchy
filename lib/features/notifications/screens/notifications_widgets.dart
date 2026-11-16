import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reviewerData = review['reviewer'] ?? {};
    final reviewerName = reviewerData['first_name'] ?? l10n.anonymous;
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final createdAt = review['created_at'] ?? '';

    String timeAgo = '';
    try {
      if (createdAt.isNotEmpty) {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final diff = now.difference(date);
        if (diff.inDays > 0) {
          timeAgo = l10n.daysAgo(diff.inDays);
        } else if (diff.inHours > 0) {
          timeAgo = l10n.hoursAgo(diff.inHours);
        } else {
          timeAgo = l10n.minutesAgo(diff.inMinutes);
        }
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reviewerName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.accent,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeAgo,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.isEmpty ? l10n.noComment : comment,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class EventsList extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final bool completed;

  const EventsList({super.key, required this.events, this.completed = false});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return MyEventCard(event: event, completed: completed);
      },
    );
  }
}

class MyEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool completed;

  const MyEventCard({super.key, required this.event, this.completed = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eventData = event['event'] ?? {};
    final title = eventData['title'] ?? l10n.noTitle;
    final location = eventData['location'] ?? l10n.notSpecified;
    final dateStr = eventData['date'] ?? '';
    final category = eventData['category'] ?? 'other';
    final status = event['status'] ?? 'pending';

    final categoryInfo = appCategories.firstWhere(
      (c) => c.id == category,
      orElse: () => appCategories[0],
    );

    DateTime? eventDate;
    try {
      if (dateStr.isNotEmpty) {
        eventDate = DateTime.parse(dateStr);
      }
    } catch (_) {}

    String statusText = '';
    Color statusColor = AppColors.textSecondary;
    switch (status) {
      case 'approved':
        statusText = l10n.approved;
        statusColor = AppColors.success;
        break;
      case 'pending':
        statusText = l10n.pending;
        statusColor = AppColors.accent;
        break;
      case 'rejected':
        statusText = l10n.rejected;
        statusColor = AppColors.error;
        break;
      case 'attended':
        statusText = l10n.attended;
        statusColor = AppColors.success;
        break;
      case 'missed':
        statusText = l10n.missed;
        statusColor = AppColors.error;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: categoryInfo.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(categoryInfo.icon, color: categoryInfo.color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (eventDate != null)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${eventDate.day}.${eventDate.month}.${eventDate.year}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                if (completed) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      final organizerId = eventData['organizer'];
                      if (organizerId != null) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ReviewBottomSheet(
                            event: VolunteerEvent.fromJson(eventData),
                            targetUserId: organizerId,
                          ),
                        );
                      }
                    },
                    child: Text(
                      l10n.leaveReview,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewBottomSheet extends StatefulWidget {
  final VolunteerEvent event;
  final int targetUserId;

  const ReviewBottomSheet({super.key, required this.event, required this.targetUserId});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 24),
          Text(
            l10n.leaveReviewTitle,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.rateEvent(widget.event.title),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.accent,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 15),
            decoration: InputDecoration(
              hintText: l10n.shareImpression,
              hintStyle: GoogleFonts.inter(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _rating == 0
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    setState(() => _isSubmitting = true);
                    try {
                      final apiClient = ApiClient();
                      await apiClient.dio.post(
                        '/reviews/',
                        data: {
                          'target_user': widget.targetUserId,
                          'rating': _rating,
                          'comment': _commentController.text.trim(),
                        },
                      );
                      if (!mounted) return;
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.thankYouForReview, style: GoogleFonts.inter(color: Colors.white)),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _isSubmitting = false);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.error('$e'), style: GoogleFonts.inter(color: Colors.white)),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _rating > 0 ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        l10n.send,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _rating > 0 ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InitiativeCard extends StatelessWidget {
  final Initiative initiative;

  const InitiativeCard({super.key, required this.initiative});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = initiative.title.isEmpty ? l10n.noTitle : initiative.title;
    final description = initiative.description;
    final status = initiative.status;
    String statusText = '';
    Color statusColor = AppColors.textSecondary;
    switch (status) {
      case 'approved':
        statusText = l10n.approved;
        statusColor = AppColors.success;
        break;
      case 'pending':
        statusText = l10n.onModeration;
        statusColor = AppColors.accent;
        break;
      case 'rejected':
        statusText = l10n.rejected;
        statusColor = AppColors.error;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.small,
        border: status == 'approved' ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SettingsCard({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }
}

class SettingSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}

class LangOption extends StatelessWidget {
  final String flag;
  final String name;
  final String subtitle;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const LangOption({
    super.key,
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: AppShadows.small,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

