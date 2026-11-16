import 'package:flutter/material.dart';
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
                  onChanged: (v) => setState(() => _pushEvents = v),
                ),
                SettingSwitch(
                  title: l10n.invitationsFromNGO,
                  subtitle: l10n.invitationsSubtitle,
                  value: _pushInvitations,
                  onChanged: (v) => setState(() => _pushInvitations = v),
                ),
                SettingSwitch(
                  title: l10n.newReviews,
                  subtitle: l10n.newReviewsSubtitle,
                  value: _pushReviews,
                  onChanged: (v) => setState(() => _pushReviews = v),
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
                  onChanged: (v) => setState(() => _whatsappReminders = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
