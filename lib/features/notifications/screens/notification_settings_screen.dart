import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/core/utils/debug_i18n_logger.dart';
import 'package:volunteering/features/notifications/screens/notifications_widgets.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEvents = true;
  bool _pushInvitations = true;
  bool _pushReviews = true;
  bool _whatsappReminders = false;

  // Persisted locally so choices survive leaving the screen / restarting the app
  static const _kEvents = 'notif_push_events';
  static const _kInvitations = 'notif_push_invitations';
  static const _kReviews = 'notif_push_reviews';
  static const _kWhatsapp = 'notif_whatsapp_reminders';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pushEvents = prefs.getBool(_kEvents) ?? true;
      _pushInvitations = prefs.getBool(_kInvitations) ?? true;
      _pushReviews = prefs.getBool(_kReviews) ?? true;
      _whatsappReminders = prefs.getBool(_kWhatsapp) ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    logI18nDebug(
      runId: 'baseline',
      hypothesisId: 'H4',
      location: 'other_screens.dart:NotificationSettingsScreen',
      message: 'Notification settings localized labels',
      data: {
        'locale': Localizations.localeOf(context).languageCode,
        'title': l10n.notificationSettings,
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SettingsCard(
              title: l10n.pushNotifications,
              items: [
                SettingSwitch(
                  title: l10n.newEvents,
                  subtitle: l10n.newEventsSubtitle,
                  value: _pushEvents,
                  onChanged: (v) {
                    setState(() => _pushEvents = v);
                    _save(_kEvents, v);
                  },
                ),
                SettingSwitch(
                  title: l10n.invitationsFromNGO,
                  subtitle: l10n.invitationsSubtitle,
                  value: _pushInvitations,
                  onChanged: (v) {
                    setState(() => _pushInvitations = v);
                    _save(_kInvitations, v);
                  },
                ),
                SettingSwitch(
                  title: l10n.newReviews,
                  subtitle: l10n.newReviewsSubtitle,
                  value: _pushReviews,
                  onChanged: (v) {
                    setState(() => _pushReviews = v);
                    _save(_kReviews, v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsCard(
              title: l10n.whatsapp,
              items: [
                SettingSwitch(
                  title: l10n.eventReminders,
                  subtitle: l10n.eventRemindersSubtitle,
                  value: _whatsappReminders,
                  onChanged: (v) {
                    setState(() => _whatsappReminders = v);
                    _save(_kWhatsapp, v);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
