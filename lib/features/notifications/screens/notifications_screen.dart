import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/core/providers/notifications_provider.dart';
import 'package:volunteering/data/models/models.dart';


// ============================================================
// NOTIFICATIONS SCREEN
// ============================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  void _markAllRead() {
    final l10n = AppLocalizations.of(context)!;
    context.read<NotificationsProvider>().markAllAsRead();
    AppSnackbar.showSuccess(context, l10n.notificationsMarkedRead);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, child) {
        final notifications = provider.notifications;
        final unreadCount = provider.unreadCount;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.notifications),
            actions: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: _markAllRead,
                  child: Text(AppLocalizations.of(context)!.readAllNotifications,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          backgroundColor: AppColors.background,
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return GestureDetector(
                          onTap: () {
                            final id = int.tryParse(notif.id);
                            if (id != null) provider.markAsRead(id);
                          },
                          child: _NotificationCard(notificationData: notif),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(l10n.noNotifications,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l10n.noNotificationsSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notificationData;

  const _NotificationCard({required this.notificationData});

  String get type => notificationData.type;
  String title(AppLocalizations l10n) => notificationData.title.isEmpty ? l10n.noTitle : notificationData.title;
  String get body => notificationData.body;
  bool get isRead => notificationData.isRead;
  String get createdAt => notificationData.date.toIso8601String();

  IconData get _icon {
    switch (type) {
      case 'invitation':
        return Icons.mail_rounded;
      case 'registration_status':
        return Icons.assignment_turned_in_rounded;
      case 'event_update':
        return Icons.update_rounded;
      case 'system':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get _color {
    switch (type) {
      case 'invitation':
        return const Color(0xFF311b92);
      case 'registration_status':
        return AppColors.success;
      case 'event_update':
        return AppColors.info;
      case 'system':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  String _timeAgo(String dateStr, AppLocalizations l10n) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return l10n.daysAgo(diff.inDays);
      if (diff.inHours > 0) return l10n.hoursAgo(diff.inHours);
      if (diff.inMinutes > 0) return l10n.minutesAgo(diff.inMinutes);
      return l10n.justNow;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : _color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: isRead
            ? null
            : Border.all(color: _color.withValues(alpha: 0.2), width: 1),
        boxShadow: AppShadows.small,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title(l10n),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(createdAt, l10n),
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
