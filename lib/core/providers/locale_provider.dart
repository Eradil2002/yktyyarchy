import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunteering/core/utils/debug_i18n_logger.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale = const Locale('ru');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        _locale = Locale(localeCode);
        // #region agent log
        logI18nDebug(
          runId: 'baseline',
          hypothesisId: 'H1',
          location: 'locale_provider.dart:_loadLocale',
          message: 'Loaded locale from storage',
          data: {'localeCode': localeCode},
        );
        // #endregion
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    // #region agent log
    logI18nDebug(
      runId: 'baseline',
      hypothesisId: 'H1',
      location: 'locale_provider.dart:setLocale',
      message: 'Locale change requested',
      data: {'from': _locale.languageCode, 'to': locale.languageCode},
    );
    // #endregion
    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  void clearLocale() {
    _locale = const Locale('ru');
    notifyListeners();
  }
}
