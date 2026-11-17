import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/core/providers/locale_provider.dart';
import 'package:volunteering/core/utils/debug_i18n_logger.dart';
import 'package:volunteering/features/notifications/screens/notifications_widgets.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final l10n = AppLocalizations.of(context)!;
        final currentLocale = localeProvider.locale.languageCode;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.languageSettings)),
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LangOption(
                  flag: '🇷🇺',
                  name: l10n.russian,
                  subtitle: l10n.russianNative,
                  code: 'ru',
                  isSelected: currentLocale == 'ru',
                  onTap: () {
                    logI18nDebug(
                      runId: 'baseline',
                      hypothesisId: 'H1',
                      location: 'other_screens.dart:LanguageSettingsScreen',
                      message: 'Language option tapped',
                      data: {'current': currentLocale, 'selected': 'ru'},
                    );
                    localeProvider.setLocale(const Locale('ru'));
                  },
                ),
                const SizedBox(height: 12),
                LangOption(
                  flag: '🇰🇬',
                  name: l10n.kyrgyz,
                  subtitle: l10n.kyrgyzNative,
                  code: 'ky',
                  isSelected: currentLocale == 'ky',
                  onTap: () {
                    logI18nDebug(
                      runId: 'baseline',
                      hypothesisId: 'H1',
                      location: 'other_screens.dart:LanguageSettingsScreen',
                      message: 'Language option tapped',
                      data: {'current': currentLocale, 'selected': 'ky'},
                    );
                    localeProvider.setLocale(const Locale('ky'));
                  },
                ),
                const SizedBox(height: 12),
                LangOption(
                  flag: '🇬🇧',
                  name: l10n.english,
                  subtitle: l10n.englishNative,
                  code: 'en',
                  isSelected: currentLocale == 'en',
                  onTap: () => localeProvider.setLocale(const Locale('en')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

