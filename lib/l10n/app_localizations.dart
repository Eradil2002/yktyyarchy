import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ky.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ky'),
    Locale('ru')
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Ыктыярчы'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ru, this message translates to:
  /// **'Платформа волонтеров Кыргызстана'**
  String get appTagline;

  /// No description provided for @volunteersCount.
  ///
  /// In ru, this message translates to:
  /// **'Волонтеров'**
  String get volunteersCount;

  /// No description provided for @organizationsCount.
  ///
  /// In ru, this message translates to:
  /// **'Организаций'**
  String get organizationsCount;

  /// No description provided for @eventsCount.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятий'**
  String get eventsCount;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// No description provided for @loginToAccount.
  ///
  /// In ru, this message translates to:
  /// **'Войти в аккаунт'**
  String get loginToAccount;

  /// No description provided for @joinGoodDeeds.
  ///
  /// In ru, this message translates to:
  /// **'Присоединяйтесь к добрым делам'**
  String get joinGoodDeeds;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Вход в аккаунт'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы продолжить'**
  String get loginSubtitle;

  /// No description provided for @usernameOrEmail.
  ///
  /// In ru, this message translates to:
  /// **'Username или Email'**
  String get usernameOrEmail;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? '**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerLink;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get register;

  /// No description provided for @registerSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте аккаунт волонтера'**
  String get registerSubtitle;

  /// No description provided for @accountType.
  ///
  /// In ru, this message translates to:
  /// **'Тип аккаунта'**
  String get accountType;

  /// No description provided for @volunteer.
  ///
  /// In ru, this message translates to:
  /// **'Волонтер'**
  String get volunteer;

  /// No description provided for @ngo.
  ///
  /// In ru, this message translates to:
  /// **'НКО'**
  String get ngo;

  /// No description provided for @firstName.
  ///
  /// In ru, this message translates to:
  /// **'Имя *'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия *'**
  String get lastName;

  /// No description provided for @username.
  ///
  /// In ru, this message translates to:
  /// **'Username *'**
  String get username;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Email *'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон (необязательно)'**
  String get phone;

  /// No description provided for @passwordConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль *'**
  String get passwordConfirm;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 8 символов'**
  String get passwordHint;

  /// No description provided for @repeatPassword.
  ///
  /// In ru, this message translates to:
  /// **'Повторите пароль'**
  String get repeatPassword;

  /// No description provided for @agreeWith.
  ///
  /// In ru, this message translates to:
  /// **'Я согласен с '**
  String get agreeWith;

  /// No description provided for @termsOfService.
  ///
  /// In ru, this message translates to:
  /// **'Условиями использования'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In ru, this message translates to:
  /// **' и '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Политикой конфиденциальности'**
  String get privacyPolicy;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerButton;

  /// No description provided for @haveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? '**
  String get haveAccount;

  /// No description provided for @loginLink.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginLink;

  /// No description provided for @fillAllFields.
  ///
  /// In ru, this message translates to:
  /// **'Заполните все поля'**
  String get fillAllFields;

  /// No description provided for @fillAllRequiredFields.
  ///
  /// In ru, this message translates to:
  /// **'Заполните все обязательные поля'**
  String get fillAllRequiredFields;

  /// No description provided for @agreeToTermsRequired.
  ///
  /// In ru, this message translates to:
  /// **'Необходимо согласиться с условиями использования и политикой конфиденциальности'**
  String get agreeToTermsRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMinLength.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен быть минимум 8 символов'**
  String get passwordMinLength;

  /// No description provided for @hello.
  ///
  /// In ru, this message translates to:
  /// **'Привет, {name}!'**
  String hello(String name);

  /// No description provided for @hours.
  ///
  /// In ru, this message translates to:
  /// **'часов'**
  String get hours;

  /// No description provided for @badges.
  ///
  /// In ru, this message translates to:
  /// **'бейджей'**
  String get badges;

  /// No description provided for @rating.
  ///
  /// In ru, this message translates to:
  /// **'рейтинг'**
  String get rating;

  /// No description provided for @searchPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Где я могу помочь сегодня?'**
  String get searchPlaceholder;

  /// No description provided for @nearby.
  ///
  /// In ru, this message translates to:
  /// **'Рядом'**
  String get nearby;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @urgent.
  ///
  /// In ru, this message translates to:
  /// **'Срочно'**
  String get urgent;

  /// No description provided for @categories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categories;

  /// No description provided for @loadingError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки: {error}'**
  String loadingError(String error);

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @noEventsFound.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятий не найдено'**
  String get noEventsFound;

  /// No description provided for @noEventsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить фильтры или поисковый запрос'**
  String get noEventsSubtitle;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @filtersSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Уточните результаты поиска'**
  String get filtersSubtitle;

  /// No description provided for @format.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get format;

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @offline.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн'**
  String get online;

  /// No description provided for @urgentOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только срочные'**
  String get urgentOnly;

  /// No description provided for @urgentOnlySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Показывать только срочные мероприятия'**
  String get urgentOnlySubtitle;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @tomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get tomorrow;

  /// No description provided for @participantsOf.
  ///
  /// In ru, this message translates to:
  /// **'{current} из {total} участников'**
  String participantsOf(int current, int total);

  /// No description provided for @myActivity.
  ///
  /// In ru, this message translates to:
  /// **'Моя активность'**
  String get myActivity;

  /// No description provided for @myEvents.
  ///
  /// In ru, this message translates to:
  /// **'Мои мероприятия'**
  String get myEvents;

  /// No description provided for @myEventsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Участия'**
  String get myEventsSubtitle;

  /// No description provided for @myInitiatives.
  ///
  /// In ru, this message translates to:
  /// **'Мои инициативы'**
  String get myInitiatives;

  /// No description provided for @myInitiativesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Добрые дела'**
  String get myInitiativesSubtitle;

  /// No description provided for @achievements.
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get achievements;

  /// No description provided for @achievementsReceived.
  ///
  /// In ru, this message translates to:
  /// **'{count} получено'**
  String achievementsReceived(int count);

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать профиль'**
  String get editProfile;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Фото, ФИО, локация'**
  String get editProfileSubtitle;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки push-уведомлений'**
  String get notificationsSubtitle;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @aboutApp.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutApp;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Как мы защищаем ваши данные'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get termsOfServiceTitle;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Правила и соглашения'**
  String get termsOfServiceSubtitle;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get logout;

  /// No description provided for @volunteerBook.
  ///
  /// In ru, this message translates to:
  /// **'Электронная книжка волонтера'**
  String get volunteerBook;

  /// No description provided for @confirmedHours.
  ///
  /// In ru, this message translates to:
  /// **'{hours} подтвержденных часов'**
  String confirmedHours(int hours);

  /// No description provided for @open.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get open;

  /// No description provided for @allAchievements.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get allAchievements;

  /// No description provided for @achievementsCount.
  ///
  /// In ru, this message translates to:
  /// **'{unlocked} из {total} получено'**
  String achievementsCount(int unlocked, int total);

  /// No description provided for @reviewsFromOrganizations.
  ///
  /// In ru, this message translates to:
  /// **'Отзывы от организаций'**
  String get reviewsFromOrganizations;

  /// No description provided for @allReviews.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get allReviews;

  /// No description provided for @daysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{days} дн. назад'**
  String daysAgo(int days);

  /// No description provided for @monthsAgo.
  ///
  /// In ru, this message translates to:
  /// **'{months} мес. назад'**
  String monthsAgo(int months);

  /// No description provided for @todayLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get todayLabel;

  /// No description provided for @received.
  ///
  /// In ru, this message translates to:
  /// **'✓ Получено'**
  String get received;

  /// No description provided for @ngoProfileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль НКО'**
  String get ngoProfileTitle;

  /// No description provided for @orgNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название организации *'**
  String get orgNameLabel;

  /// No description provided for @verifiedStatus.
  ///
  /// In ru, this message translates to:
  /// **'Подтвержденный статус'**
  String get verifiedStatus;

  /// No description provided for @notVerifiedStatus.
  ///
  /// In ru, this message translates to:
  /// **'Без подтверждения'**
  String get notVerifiedStatus;

  /// No description provided for @ngoEventsListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Список мероприятий'**
  String get ngoEventsListTitle;

  /// No description provided for @ngoNoEvents.
  ///
  /// In ru, this message translates to:
  /// **'У этой организации пока нет мероприятий'**
  String get ngoNoEvents;

  /// No description provided for @ngoNoDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание отсутствует'**
  String get ngoNoDescription;

  /// No description provided for @ngoEventsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} мероприятий'**
  String ngoEventsCount(int count);

  /// No description provided for @reviews.
  ///
  /// In ru, this message translates to:
  /// **'Отзывы'**
  String get reviews;

  /// No description provided for @guest.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get guest;

  /// No description provided for @organizationRating.
  ///
  /// In ru, this message translates to:
  /// **'рейтинг организации'**
  String get organizationRating;

  /// No description provided for @projectsCountShort.
  ///
  /// In ru, this message translates to:
  /// **'{count} проектов'**
  String projectsCountShort(int count);

  /// No description provided for @volunteersCountShort.
  ///
  /// In ru, this message translates to:
  /// **'{count} волонтеров'**
  String volunteersCountShort(int count);

  /// No description provided for @distanceKm.
  ///
  /// In ru, this message translates to:
  /// **'{distance} км'**
  String distanceKm(String distance);

  /// No description provided for @registeredCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} записалось'**
  String registeredCount(int count);

  /// No description provided for @hoursShort.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч'**
  String hoursShort(int hours);

  /// No description provided for @todayAt.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня в {time}'**
  String todayAt(String time);

  /// No description provided for @spotsAvailable.
  ///
  /// In ru, this message translates to:
  /// **'✓ Есть {count} мест'**
  String spotsAvailable(int count);

  /// No description provided for @noSpots.
  ///
  /// In ru, this message translates to:
  /// **'✗ Мест нет'**
  String get noSpots;

  /// No description provided for @loginToRegister.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в аккаунт, чтобы записаться'**
  String get loginToRegister;

  /// No description provided for @registeredSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Вы записались! Удачи'**
  String get registeredSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось записаться. Попробуйте позже.'**
  String get registerFailed;

  /// No description provided for @manage.
  ///
  /// In ru, this message translates to:
  /// **'Управлять'**
  String get manage;

  /// No description provided for @management.
  ///
  /// In ru, this message translates to:
  /// **'Управление'**
  String get management;

  /// No description provided for @registered.
  ///
  /// In ru, this message translates to:
  /// **'Вы записаны'**
  String get registered;

  /// No description provided for @dateAndTime.
  ///
  /// In ru, this message translates to:
  /// **'Дата и время'**
  String get dateAndTime;

  /// No description provided for @eventLocation.
  ///
  /// In ru, this message translates to:
  /// **'Место проведения'**
  String get eventLocation;

  /// No description provided for @showOnMap.
  ///
  /// In ru, this message translates to:
  /// **'Показать на карте'**
  String get showOnMap;

  /// No description provided for @participants.
  ///
  /// In ru, this message translates to:
  /// **'Участники'**
  String get participants;

  /// No description provided for @volunteerHoursLabel.
  ///
  /// In ru, this message translates to:
  /// **'Волонтерские часы'**
  String get volunteerHoursLabel;

  /// No description provided for @hoursWillBeCredited.
  ///
  /// In ru, this message translates to:
  /// **'{hours} часов будут зачислены'**
  String hoursWillBeCredited(int hours);

  /// No description provided for @descriptionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get descriptionLabel;

  /// No description provided for @requirementsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Требования'**
  String get requirementsLabel;

  /// No description provided for @titleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get titleLabel;

  /// No description provided for @eventTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Пример: Субботник в парке'**
  String get eventTitleHint;

  /// No description provided for @eventDescriptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Подробно опишите мероприятие...'**
  String get eventDescriptionHint;

  /// No description provided for @eventLocationHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите адрес или нажмите GPS'**
  String get eventLocationHint;

  /// No description provided for @hoursLabelShort.
  ///
  /// In ru, this message translates to:
  /// **'Часов'**
  String get hoursLabelShort;

  /// No description provided for @spotsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Мест'**
  String get spotsLabel;

  /// No description provided for @publishEvent.
  ///
  /// In ru, this message translates to:
  /// **'Опубликовать мероприятие'**
  String get publishEvent;

  /// No description provided for @eventCreatedSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятие успешно создано!'**
  String get eventCreatedSuccess;

  /// No description provided for @eventCreateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать мероприятие'**
  String get eventCreateFailed;

  /// No description provided for @camera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get gallery;

  /// No description provided for @added.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено'**
  String get added;

  /// No description provided for @photoNumber.
  ///
  /// In ru, this message translates to:
  /// **'Фото {number}'**
  String photoNumber(int number);

  /// No description provided for @sendForReview.
  ///
  /// In ru, this message translates to:
  /// **'Отправить на проверку'**
  String get sendForReview;

  /// No description provided for @initiativeAddBeforeAfterPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы одно фото ДО и ПОСЛЕ'**
  String get initiativeAddBeforeAfterPhotos;

  /// No description provided for @initiativeNeedGps.
  ///
  /// In ru, this message translates to:
  /// **'Сначала определите GPS-локацию'**
  String get initiativeNeedGps;

  /// No description provided for @initiativeSentForModeration.
  ///
  /// In ru, this message translates to:
  /// **'Инициатива отправлена на модерацию. Часы начислятся после проверки.'**
  String get initiativeSentForModeration;

  /// No description provided for @initiativeInfoBanner.
  ///
  /// In ru, this message translates to:
  /// **'Ключевой механизм для отдаленных регионов. Инициатива проходит модерацию перед подтверждением.'**
  String get initiativeInfoBanner;

  /// No description provided for @initiativeTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Уборка берега реки'**
  String get initiativeTitleHint;

  /// No description provided for @initiativeDescriptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Опишите ваше доброе дело...'**
  String get initiativeDescriptionHint;

  /// No description provided for @initiativeGpsCaptured.
  ///
  /// In ru, this message translates to:
  /// **'GPS зафиксирован: {lat}, {lng}'**
  String initiativeGpsCaptured(String lat, String lng);

  /// No description provided for @initiativeResolveGps.
  ///
  /// In ru, this message translates to:
  /// **'Определить мою локацию (GPS)'**
  String get initiativeResolveGps;

  /// No description provided for @liveCamera.
  ///
  /// In ru, this message translates to:
  /// **'Live-камера'**
  String get liveCamera;

  /// No description provided for @liveCameraDescription.
  ///
  /// In ru, this message translates to:
  /// **'Включите для фото в реальном времени. Это снижает риск накруток.'**
  String get liveCameraDescription;

  /// No description provided for @initiativeModerationPending.
  ///
  /// In ru, this message translates to:
  /// **'Статус модерации: на проверке'**
  String get initiativeModerationPending;

  /// No description provided for @initiativeModerationDraft.
  ///
  /// In ru, this message translates to:
  /// **'Статус модерации: черновик, еще не отправлено'**
  String get initiativeModerationDraft;

  /// No description provided for @initiativeBeforePhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фото ДО ({count}/3)'**
  String initiativeBeforePhotos(int count);

  /// No description provided for @initiativeAfterPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фото ПОСЛЕ ({count}/3)'**
  String initiativeAfterPhotos(int count);

  /// No description provided for @initiativeSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Инициатива успешно отправлена'**
  String get initiativeSuccess;

  /// No description provided for @submitting.
  ///
  /// In ru, this message translates to:
  /// **'Отправка...'**
  String get submitting;

  /// No description provided for @notificationsMarkedRead.
  ///
  /// In ru, this message translates to:
  /// **'Все уведомления прочитаны'**
  String get notificationsMarkedRead;

  /// No description provided for @readAllNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Прочитать все'**
  String get readAllNotifications;

  /// No description provided for @noNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Нет уведомлений'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда появятся новые уведомления, они будут здесь'**
  String get noNotificationsSubtitle;

  /// No description provided for @justNow.
  ///
  /// In ru, this message translates to:
  /// **'только что'**
  String get justNow;

  /// No description provided for @newSkill.
  ///
  /// In ru, this message translates to:
  /// **'Новый навык'**
  String get newSkill;

  /// No description provided for @skillExampleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Дизайн'**
  String get skillExampleHint;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Профиль успешно обновлен!'**
  String get profileUpdatedSuccess;

  /// No description provided for @savingError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сохранения'**
  String get savingError;

  /// No description provided for @mainInformation.
  ///
  /// In ru, this message translates to:
  /// **'Основная информация'**
  String get mainInformation;

  /// No description provided for @firstNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get lastNameLabel;

  /// No description provided for @locationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Локация'**
  String get locationLabel;

  /// No description provided for @aboutMeLabel.
  ///
  /// In ru, this message translates to:
  /// **'О себе'**
  String get aboutMeLabel;

  /// No description provided for @skillsSection.
  ///
  /// In ru, this message translates to:
  /// **'Навыки'**
  String get skillsSection;

  /// No description provided for @enterField.
  ///
  /// In ru, this message translates to:
  /// **'Введите {field}'**
  String enterField(String field);

  /// No description provided for @offlineScheduleLoaded.
  ///
  /// In ru, this message translates to:
  /// **'Показано кэшированное расписание зарегистрированных мероприятий (offline режим).'**
  String get offlineScheduleLoaded;

  /// No description provided for @cachedDataFrom.
  ///
  /// In ru, this message translates to:
  /// **'Данные от {day}.{month}.{year}'**
  String cachedDataFrom(int day, int month, int year);

  /// No description provided for @searchOnMapPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Поиск на карте'**
  String get searchOnMapPlaceholder;

  /// No description provided for @onMapCount.
  ///
  /// In ru, this message translates to:
  /// **'На карте: {count}'**
  String onMapCount(int count);

  /// No description provided for @findingYou.
  ///
  /// In ru, this message translates to:
  /// **'Ищем вас...'**
  String get findingYou;

  /// No description provided for @eventFallbackTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятие'**
  String get eventFallbackTitle;

  /// No description provided for @emailVerificationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение email'**
  String get emailVerificationTitle;

  /// No description provided for @emailVerificationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите 6-значный код из письма'**
  String get emailVerificationSubtitle;

  /// No description provided for @verifyEmailButton.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить email'**
  String get verifyEmailButton;

  /// No description provided for @resendCode.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код повторно'**
  String get resendCode;

  /// No description provided for @verificationCodeInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный 6-значный код'**
  String get verificationCodeInvalid;

  /// No description provided for @emailVerifiedSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Email успешно подтвержден'**
  String get emailVerifiedSuccess;

  /// No description provided for @verificationFailed.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка подтверждения email'**
  String get verificationFailed;

  /// No description provided for @verificationCodeResent.
  ///
  /// In ru, this message translates to:
  /// **'Код подтверждения отправлен повторно'**
  String get verificationCodeResent;

  /// No description provided for @verificationResendFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить код повторно'**
  String get verificationResendFailed;

  /// No description provided for @whatsappAuthButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти через WhatsApp'**
  String get whatsappAuthButton;

  /// No description provided for @whatsappLoginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Авторизация через WhatsApp'**
  String get whatsappLoginTitle;

  /// No description provided for @whatsappLoginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона и получите OTP код в WhatsApp'**
  String get whatsappLoginSubtitle;

  /// No description provided for @whatsappPhoneRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона'**
  String get whatsappPhoneRequired;

  /// No description provided for @sendCodeWhatsApp.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код в WhatsApp'**
  String get sendCodeWhatsApp;

  /// No description provided for @whatsappCodeSent.
  ///
  /// In ru, this message translates to:
  /// **'Код отправлен в WhatsApp'**
  String get whatsappCodeSent;

  /// No description provided for @whatsappCodeSendFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить WhatsApp код'**
  String get whatsappCodeSendFailed;

  /// No description provided for @whatsappVerifyButton.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить код'**
  String get whatsappVerifyButton;

  /// No description provided for @enterVerificationCode.
  ///
  /// In ru, this message translates to:
  /// **'Введите код подтверждения'**
  String get enterVerificationCode;

  /// No description provided for @reviewsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} отзывов'**
  String reviewsCount(int count);

  /// No description provided for @anonymous.
  ///
  /// In ru, this message translates to:
  /// **'Аноним'**
  String get anonymous;

  /// No description provided for @hoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч. назад'**
  String hoursAgo(int hours);

  /// No description provided for @minutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин. назад'**
  String minutesAgo(int minutes);

  /// No description provided for @noComment.
  ///
  /// In ru, this message translates to:
  /// **'Без комментария'**
  String get noComment;

  /// No description provided for @loadingReviewsError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки отзывов: {error}'**
  String loadingReviewsError(String error);

  /// No description provided for @upcoming.
  ///
  /// In ru, this message translates to:
  /// **'Предстоящие'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In ru, this message translates to:
  /// **'Прошедшие'**
  String get past;

  /// No description provided for @noTitle.
  ///
  /// In ru, this message translates to:
  /// **'Без названия'**
  String get noTitle;

  /// No description provided for @notSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Не указано'**
  String get notSpecified;

  /// No description provided for @approved.
  ///
  /// In ru, this message translates to:
  /// **'Одобрено'**
  String get approved;

  /// No description provided for @pending.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In ru, this message translates to:
  /// **'Отклонено'**
  String get rejected;

  /// No description provided for @attended.
  ///
  /// In ru, this message translates to:
  /// **'Посещено'**
  String get attended;

  /// No description provided for @missed.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено'**
  String get missed;

  /// No description provided for @leaveReview.
  ///
  /// In ru, this message translates to:
  /// **'Оставить отзыв →'**
  String get leaveReview;

  /// No description provided for @leaveReviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оставить отзыв'**
  String get leaveReviewTitle;

  /// No description provided for @rateEvent.
  ///
  /// In ru, this message translates to:
  /// **'Оцените мероприятие \"{title}\"'**
  String rateEvent(String title);

  /// No description provided for @shareImpression.
  ///
  /// In ru, this message translates to:
  /// **'Поделитесь впечатлениями (необязательно)'**
  String get shareImpression;

  /// No description provided for @send.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get send;

  /// No description provided for @thankYouForReview.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо за ваш отзыв!'**
  String get thankYouForReview;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String error(String error);

  /// No description provided for @onModeration.
  ///
  /// In ru, this message translates to:
  /// **'На модерации'**
  String get onModeration;

  /// No description provided for @newInitiative.
  ///
  /// In ru, this message translates to:
  /// **'Новое дело'**
  String get newInitiative;

  /// No description provided for @notificationSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки уведомлений'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Push-уведомления'**
  String get pushNotifications;

  /// No description provided for @newEvents.
  ///
  /// In ru, this message translates to:
  /// **'Новые мероприятия'**
  String get newEvents;

  /// No description provided for @newEventsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'По вашим категориям'**
  String get newEventsSubtitle;

  /// No description provided for @invitationsFromNGO.
  ///
  /// In ru, this message translates to:
  /// **'Приглашения от НКО'**
  String get invitationsFromNGO;

  /// No description provided for @invitationsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда организация вас приглашает'**
  String get invitationsSubtitle;

  /// No description provided for @newReviews.
  ///
  /// In ru, this message translates to:
  /// **'Новые отзывы'**
  String get newReviews;

  /// No description provided for @newReviewsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда НКО оставляет отзыв'**
  String get newReviewsSubtitle;

  /// No description provided for @whatsapp.
  ///
  /// In ru, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @eventReminders.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания о событиях'**
  String get eventReminders;

  /// No description provided for @eventRemindersSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'За 24 часа до начала'**
  String get eventRemindersSubtitle;

  /// No description provided for @languageSettings.
  ///
  /// In ru, this message translates to:
  /// **'Язык / Тил'**
  String get languageSettings;

  /// No description provided for @russian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @russianNative.
  ///
  /// In ru, this message translates to:
  /// **'Russian'**
  String get russianNative;

  /// No description provided for @kyrgyz.
  ///
  /// In ru, this message translates to:
  /// **'Кыргызча'**
  String get kyrgyz;

  /// No description provided for @kyrgyzNative.
  ///
  /// In ru, this message translates to:
  /// **'Kyrgyz'**
  String get kyrgyzNative;

  /// No description provided for @homeMenu.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homeMenu;

  /// No description provided for @mapMenu.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get mapMenu;

  /// No description provided for @talentsMenu.
  ///
  /// In ru, this message translates to:
  /// **'Таланты'**
  String get talentsMenu;

  /// No description provided for @profileMenu.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileMenu;

  /// No description provided for @createWhatTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что хотите создать?'**
  String get createWhatTitle;

  /// No description provided for @createWhatSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите тип активности'**
  String get createWhatSubtitle;

  /// No description provided for @createEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятие'**
  String get createEventTitle;

  /// No description provided for @createEventSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Для НКО и организаторов — официальные события с записью'**
  String get createEventSubtitle;

  /// No description provided for @createInitiativeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доброе дело'**
  String get createInitiativeTitle;

  /// No description provided for @createInitiativeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Для жителей сел и городов — локальная помощь без НКО'**
  String get createInitiativeSubtitle;

  /// No description provided for @talentsOnlyOrganizers.
  ///
  /// In ru, this message translates to:
  /// **'доступно только для организаторов'**
  String get talentsOnlyOrganizers;

  /// No description provided for @talentRadarOnlyForOrganizers.
  ///
  /// In ru, this message translates to:
  /// **'Радар талантов доступен только аккаунтам организаторов.'**
  String get talentRadarOnlyForOrganizers;

  /// No description provided for @talentRadarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Радар талантов'**
  String get talentRadarTitle;

  /// No description provided for @talentRadarSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Найдите лучших волонтеров для вашего проекта'**
  String get talentRadarSubtitle;

  /// No description provided for @talentFoundCount.
  ///
  /// In ru, this message translates to:
  /// **'Найдено: {count} лучших волонтеров'**
  String talentFoundCount(int count);

  /// No description provided for @talentSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по имени...'**
  String get talentSearchHint;

  /// No description provided for @talentMinRating.
  ///
  /// In ru, this message translates to:
  /// **'Мин. рейтинг:'**
  String get talentMinRating;

  /// No description provided for @talentCity.
  ///
  /// In ru, this message translates to:
  /// **'Город:'**
  String get talentCity;

  /// No description provided for @talentSkill.
  ///
  /// In ru, this message translates to:
  /// **'Навык:'**
  String get talentSkill;

  /// No description provided for @talentRadius.
  ///
  /// In ru, this message translates to:
  /// **'Радиус: {km} км'**
  String talentRadius(int km);

  /// No description provided for @talentResetFilters.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get talentResetFilters;

  /// No description provided for @invite.
  ///
  /// In ru, this message translates to:
  /// **'Пригласить'**
  String get invite;

  /// No description provided for @invitePerson.
  ///
  /// In ru, this message translates to:
  /// **'Пригласить {name}'**
  String invitePerson(String name);

  /// No description provided for @chooseEventForInvite.
  ///
  /// In ru, this message translates to:
  /// **'Выберите мероприятие для приглашения:'**
  String get chooseEventForInvite;

  /// No description provided for @noEventsForInvite.
  ///
  /// In ru, this message translates to:
  /// **'У вас пока нет активных мероприятий для приглашения.'**
  String get noEventsForInvite;

  /// No description provided for @inviteProjectTitle.
  ///
  /// In ru, this message translates to:
  /// **'Приглашение на проект!'**
  String get inviteProjectTitle;

  /// No description provided for @inviteProjectBody.
  ///
  /// In ru, this message translates to:
  /// **'Организация приглашает вас на мероприятие \"{eventTitle}\".'**
  String inviteProjectBody(String eventTitle);

  /// No description provided for @inviteSentSuccess.
  ///
  /// In ru, this message translates to:
  /// **'✅ Приглашение успешно отправлено!'**
  String get inviteSentSuccess;

  /// No description provided for @inviteSendError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка отправки: {error}'**
  String inviteSendError(String error);

  /// No description provided for @sendInvite.
  ///
  /// In ru, this message translates to:
  /// **'Отправить приглашение'**
  String get sendInvite;

  /// No description provided for @orgShort.
  ///
  /// In ru, this message translates to:
  /// **'НКО'**
  String get orgShort;

  /// No description provided for @cityOsh.
  ///
  /// In ru, this message translates to:
  /// **'Ош'**
  String get cityOsh;

  /// No description provided for @cityKarakol.
  ///
  /// In ru, this message translates to:
  /// **'Каракол'**
  String get cityKarakol;

  /// No description provided for @cityNaryn.
  ///
  /// In ru, this message translates to:
  /// **'Нарын'**
  String get cityNaryn;

  /// No description provided for @cityJalalAbad.
  ///
  /// In ru, this message translates to:
  /// **'Джалал-Абад'**
  String get cityJalalAbad;

  /// No description provided for @skillMedicine.
  ///
  /// In ru, this message translates to:
  /// **'Медицина'**
  String get skillMedicine;

  /// No description provided for @skillPedagogy.
  ///
  /// In ru, this message translates to:
  /// **'Педагогика'**
  String get skillPedagogy;

  /// No description provided for @skillConstruction.
  ///
  /// In ru, this message translates to:
  /// **'Строительство'**
  String get skillConstruction;

  /// No description provided for @skillPhotography.
  ///
  /// In ru, this message translates to:
  /// **'Фотография'**
  String get skillPhotography;

  /// No description provided for @categoryEcology.
  ///
  /// In ru, this message translates to:
  /// **'Экология'**
  String get categoryEcology;

  /// No description provided for @categoryEducation.
  ///
  /// In ru, this message translates to:
  /// **'Образование'**
  String get categoryEducation;

  /// No description provided for @categoryHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get categoryHealth;

  /// No description provided for @categorySocial.
  ///
  /// In ru, this message translates to:
  /// **'Соц. помощь'**
  String get categorySocial;

  /// No description provided for @categoryAnimals.
  ///
  /// In ru, this message translates to:
  /// **'Животные'**
  String get categoryAnimals;

  /// No description provided for @categoryCulture.
  ///
  /// In ru, this message translates to:
  /// **'Культура'**
  String get categoryCulture;

  /// No description provided for @categorySport.
  ///
  /// In ru, this message translates to:
  /// **'Спорт'**
  String get categorySport;

  /// No description provided for @categoryOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get categoryOther;

  /// No description provided for @kyrgyzstan.
  ///
  /// In ru, this message translates to:
  /// **'Кыргызстан'**
  String get kyrgyzstan;

  /// No description provided for @bishkek.
  ///
  /// In ru, this message translates to:
  /// **'Бишкек'**
  String get bishkek;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'ОК'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @exportPdf.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт PDF'**
  String get exportPdf;

  /// No description provided for @noEntriesYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет записей'**
  String get noEntriesYet;

  /// No description provided for @dateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get dateLabel;

  /// No description provided for @activityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Активность'**
  String get activityLabel;

  /// No description provided for @hoursLabel.
  ///
  /// In ru, this message translates to:
  /// **'Часы'**
  String get hoursLabel;

  /// No description provided for @statusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get statusLabel;

  /// No description provided for @recentlyViewed.
  ///
  /// In ru, this message translates to:
  /// **'Недавно просмотренные'**
  String get recentlyViewed;

  /// No description provided for @onboardingWelcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать в Ыктыярчы'**
  String get onboardingWelcome;

  /// No description provided for @onboardingStep1.
  ///
  /// In ru, this message translates to:
  /// **'Находите мероприятия на карте и в ленте — фильтры и поиск помогут быстрее.'**
  String get onboardingStep1;

  /// No description provided for @onboardingStep2.
  ///
  /// In ru, this message translates to:
  /// **'Записывайтесь одним нажатием и следите за местами в событии.'**
  String get onboardingStep2;

  /// No description provided for @onboardingStep3.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания и история просмотров держат вас в курсе.'**
  String get onboardingStep3;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get onboardingGetStarted;

  /// No description provided for @shareEventSubject.
  ///
  /// In ru, this message translates to:
  /// **'Мероприятие: {title}'**
  String shareEventSubject(String title);

  /// No description provided for @shareEventBody.
  ///
  /// In ru, this message translates to:
  /// **'{title}\n\n{detail}'**
  String shareEventBody(String title, String detail);

  /// No description provided for @mapQuickFiltersHint.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые фильтры'**
  String get mapQuickFiltersHint;

  /// No description provided for @loadingMore.
  ///
  /// In ru, this message translates to:
  /// **'Ещё загрузка...'**
  String get loadingMore;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ky', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ky':
      return AppLocalizationsKy();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
