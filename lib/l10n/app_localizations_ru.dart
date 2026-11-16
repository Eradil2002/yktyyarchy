// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Ыктыярчы';

  @override
  String get appTagline => 'Платформа волонтеров Кыргызстана';

  @override
  String get volunteersCount => 'Волонтеров';

  @override
  String get organizationsCount => 'Организаций';

  @override
  String get eventsCount => 'Мероприятий';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get loginToAccount => 'Войти в аккаунт';

  @override
  String get joinGoodDeeds => 'Присоединяйтесь к добрым делам';

  @override
  String get login => 'Вход в аккаунт';

  @override
  String get loginSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get usernameOrEmail => 'Username или Email';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get loginButton => 'Войти';

  @override
  String get noAccount => 'Нет аккаунта? ';

  @override
  String get registerLink => 'Зарегистрироваться';

  @override
  String get register => 'Регистрация';

  @override
  String get registerSubtitle => 'Создайте аккаунт волонтера';

  @override
  String get accountType => 'Тип аккаунта';

  @override
  String get volunteer => 'Волонтер';

  @override
  String get ngo => 'НКО';

  @override
  String get firstName => 'Имя *';

  @override
  String get lastName => 'Фамилия *';

  @override
  String get username => 'Username *';

  @override
  String get email => 'Email *';

  @override
  String get phone => 'Телефон (необязательно)';

  @override
  String get passwordConfirm => 'Подтвердите пароль *';

  @override
  String get passwordHint => 'Минимум 8 символов';

  @override
  String get repeatPassword => 'Повторите пароль';

  @override
  String get agreeWith => 'Я согласен с ';

  @override
  String get termsOfService => 'Условиями использования';

  @override
  String get and => ' и ';

  @override
  String get privacyPolicy => 'Политикой конфиденциальности';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get haveAccount => 'Уже есть аккаунт? ';

  @override
  String get loginLink => 'Войти';

  @override
  String get fillAllFields => 'Заполните все поля';

  @override
  String get fillAllRequiredFields => 'Заполните все обязательные поля';

  @override
  String get agreeToTermsRequired =>
      'Необходимо согласиться с условиями использования и политикой конфиденциальности';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get passwordMinLength => 'Пароль должен быть минимум 8 символов';

  @override
  String hello(String name) {
    return 'Привет, $name!';
  }

  @override
  String get hours => 'часов';

  @override
  String get badges => 'бейджей';

  @override
  String get rating => 'рейтинг';

  @override
  String get searchPlaceholder => 'Где я могу помочь сегодня?';

  @override
  String get nearby => 'Рядом';

  @override
  String get today => 'Сегодня';

  @override
  String get urgent => 'Срочно';

  @override
  String get categories => 'Категории';

  @override
  String loadingError(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get noEventsFound => 'Мероприятий не найдено';

  @override
  String get noEventsSubtitle =>
      'Попробуйте изменить фильтры или поисковый запрос';

  @override
  String get filters => 'Фильтры';

  @override
  String get filtersSubtitle => 'Уточните результаты поиска';

  @override
  String get format => 'Формат';

  @override
  String get all => 'Все';

  @override
  String get offline => 'Офлайн';

  @override
  String get online => 'Онлайн';

  @override
  String get urgentOnly => 'Только срочные';

  @override
  String get urgentOnlySubtitle => 'Показывать только срочные мероприятия';

  @override
  String get reset => 'Сбросить';

  @override
  String get apply => 'Применить';

  @override
  String get tomorrow => 'Завтра';

  @override
  String participantsOf(int current, int total) {
    return '$current из $total участников';
  }

  @override
  String get myActivity => 'Моя активность';

  @override
  String get myEvents => 'Мои мероприятия';

  @override
  String get myEventsSubtitle => 'Участия';

  @override
  String get myInitiatives => 'Мои инициативы';

  @override
  String get myInitiativesSubtitle => 'Добрые дела';

  @override
  String get achievements => 'Достижения';

  @override
  String achievementsReceived(int count) {
    return '$count получено';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get editProfileSubtitle => 'Фото, ФИО, локация';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsSubtitle => 'Настройки push-уведомлений';

  @override
  String get language => 'Язык';

  @override
  String get languageRussian => 'Русский';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get privacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get privacyPolicySubtitle => 'Как мы защищаем ваши данные';

  @override
  String get termsOfServiceTitle => 'Условия использования';

  @override
  String get termsOfServiceSubtitle => 'Правила и соглашения';

  @override
  String get logout => 'Выйти из аккаунта';

  @override
  String get volunteerBook => 'Электронная книжка волонтера';

  @override
  String confirmedHours(int hours) {
    return '$hours подтвержденных часов';
  }

  @override
  String get open => 'Открыть';

  @override
  String get allAchievements => 'Все';

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked из $total получено';
  }

  @override
  String get reviewsFromOrganizations => 'Отзывы от организаций';

  @override
  String get allReviews => 'Все';

  @override
  String daysAgo(int days) {
    return '$days дн. назад';
  }

  @override
  String monthsAgo(int months) {
    return '$months мес. назад';
  }

  @override
  String get todayLabel => 'Сегодня';

  @override
  String get received => '✓ Получено';

  @override
  String get ngoProfileTitle => 'Профиль НКО';

  @override
  String get orgNameLabel => 'Название организации *';

  @override
  String get verifiedStatus => 'Подтвержденный статус';

  @override
  String get notVerifiedStatus => 'Без подтверждения';

  @override
  String get ngoEventsListTitle => 'Список мероприятий';

  @override
  String get ngoNoEvents => 'У этой организации пока нет мероприятий';

  @override
  String get ngoNoDescription => 'Описание отсутствует';

  @override
  String ngoEventsCount(int count) {
    return '$count мероприятий';
  }

  @override
  String get reviews => 'Отзывы';

  @override
  String get guest => 'Гость';

  @override
  String get organizationRating => 'рейтинг организации';

  @override
  String projectsCountShort(int count) {
    return '$count проектов';
  }

  @override
  String volunteersCountShort(int count) {
    return '$count волонтеров';
  }

  @override
  String distanceKm(String distance) {
    return '$distance км';
  }

  @override
  String registeredCount(int count) {
    return '$count записалось';
  }

  @override
  String hoursShort(int hours) {
    return '$hours ч';
  }

  @override
  String todayAt(String time) {
    return 'Сегодня в $time';
  }

  @override
  String spotsAvailable(int count) {
    return '✓ Есть $count мест';
  }

  @override
  String get noSpots => '✗ Мест нет';

  @override
  String get loginToRegister => 'Войдите в аккаунт, чтобы записаться';

  @override
  String get registeredSuccess => 'Вы записались! Удачи';

  @override
  String get registerFailed => 'Не удалось записаться. Попробуйте позже.';

  @override
  String get manage => 'Управлять';

  @override
  String get management => 'Управление';

  @override
  String get registered => 'Вы записаны';

  @override
  String get dateAndTime => 'Дата и время';

  @override
  String get eventLocation => 'Место проведения';

  @override
  String get showOnMap => 'Показать на карте';

  @override
  String get participants => 'Участники';

  @override
  String get volunteerHoursLabel => 'Волонтерские часы';

  @override
  String hoursWillBeCredited(int hours) {
    return '$hours часов будут зачислены';
  }

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get requirementsLabel => 'Требования';

  @override
  String get titleLabel => 'Название';

  @override
  String get eventTitleHint => 'Пример: Субботник в парке';

  @override
  String get eventDescriptionHint => 'Подробно опишите мероприятие...';

  @override
  String get eventLocationHint => 'Введите адрес или нажмите GPS';

  @override
  String get hoursLabelShort => 'Часов';

  @override
  String get spotsLabel => 'Мест';

  @override
  String get publishEvent => 'Опубликовать мероприятие';

  @override
  String get eventCreatedSuccess => 'Мероприятие успешно создано!';

  @override
  String get eventCreateFailed => 'Не удалось создать мероприятие';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get added => 'Добавлено';

  @override
  String photoNumber(int number) {
    return 'Фото $number';
  }

  @override
  String get sendForReview => 'Отправить на проверку';

  @override
  String get initiativeAddBeforeAfterPhotos =>
      'Добавьте хотя бы одно фото ДО и ПОСЛЕ';

  @override
  String get initiativeNeedGps => 'Сначала определите GPS-локацию';

  @override
  String get initiativeSentForModeration =>
      'Инициатива отправлена на модерацию. Часы начислятся после проверки.';

  @override
  String get initiativeInfoBanner =>
      'Ключевой механизм для отдаленных регионов. Инициатива проходит модерацию перед подтверждением.';

  @override
  String get initiativeTitleHint => 'Например: Уборка берега реки';

  @override
  String get initiativeDescriptionHint => 'Опишите ваше доброе дело...';

  @override
  String initiativeGpsCaptured(String lat, String lng) {
    return 'GPS зафиксирован: $lat, $lng';
  }

  @override
  String get initiativeResolveGps => 'Определить мою локацию (GPS)';

  @override
  String get liveCamera => 'Live-камера';

  @override
  String get liveCameraDescription =>
      'Включите для фото в реальном времени. Это снижает риск накруток.';

  @override
  String get initiativeModerationPending => 'Статус модерации: на проверке';

  @override
  String get initiativeModerationDraft =>
      'Статус модерации: черновик, еще не отправлено';

  @override
  String initiativeBeforePhotos(int count) {
    return 'Фото ДО ($count/3)';
  }

  @override
  String initiativeAfterPhotos(int count) {
    return 'Фото ПОСЛЕ ($count/3)';
  }

  @override
  String get initiativeSuccess => 'Инициатива успешно отправлена';

  @override
  String get submitting => 'Отправка...';

  @override
  String get notificationsMarkedRead => 'Все уведомления прочитаны';

  @override
  String get readAllNotifications => 'Прочитать все';

  @override
  String get noNotifications => 'Нет уведомлений';

  @override
  String get noNotificationsSubtitle =>
      'Когда появятся новые уведомления, они будут здесь';

  @override
  String get justNow => 'только что';

  @override
  String get newSkill => 'Новый навык';

  @override
  String get skillExampleHint => 'Например: Дизайн';

  @override
  String get profileUpdatedSuccess => 'Профиль успешно обновлен!';

  @override
  String get savingError => 'Ошибка сохранения';

  @override
  String get mainInformation => 'Основная информация';

  @override
  String get firstNameLabel => 'Имя';

  @override
  String get lastNameLabel => 'Фамилия';

  @override
  String get locationLabel => 'Локация';

  @override
  String get aboutMeLabel => 'О себе';

  @override
  String get skillsSection => 'Навыки';

  @override
  String enterField(String field) {
    return 'Введите $field';
  }

  @override
  String get offlineScheduleLoaded =>
      'Показано кэшированное расписание зарегистрированных мероприятий (offline режим).';

  @override
  String cachedDataFrom(int day, int month, int year) {
    return 'Данные от $day.$month.$year';
  }

  @override
  String get searchOnMapPlaceholder => 'Поиск на карте';

  @override
  String onMapCount(int count) {
    return 'На карте: $count';
  }

  @override
  String get findingYou => 'Ищем вас...';

  @override
  String get eventFallbackTitle => 'Мероприятие';

  @override
  String get emailVerificationTitle => 'Подтверждение email';

  @override
  String get emailVerificationSubtitle => 'Введите 6-значный код из письма';

  @override
  String get verifyEmailButton => 'Подтвердить email';

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String get verificationCodeInvalid => 'Введите корректный 6-значный код';

  @override
  String get emailVerifiedSuccess => 'Email успешно подтвержден';

  @override
  String get verificationFailed => 'Ошибка подтверждения email';

  @override
  String get verificationCodeResent => 'Код подтверждения отправлен повторно';

  @override
  String get verificationResendFailed => 'Не удалось отправить код повторно';

  @override
  String get whatsappAuthButton => 'Войти через WhatsApp';

  @override
  String get whatsappLoginTitle => 'Авторизация через WhatsApp';

  @override
  String get whatsappLoginSubtitle =>
      'Введите номер телефона и получите OTP код в WhatsApp';

  @override
  String get whatsappPhoneRequired => 'Введите номер телефона';

  @override
  String get sendCodeWhatsApp => 'Отправить код в WhatsApp';

  @override
  String get whatsappCodeSent => 'Код отправлен в WhatsApp';

  @override
  String get whatsappCodeSendFailed => 'Не удалось отправить WhatsApp код';

  @override
  String get whatsappVerifyButton => 'Подтвердить код';

  @override
  String get enterVerificationCode => 'Введите код подтверждения';

  @override
  String reviewsCount(int count) {
    return '$count отзывов';
  }

  @override
  String get anonymous => 'Аноним';

  @override
  String hoursAgo(int hours) {
    return '$hours ч. назад';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes мин. назад';
  }

  @override
  String get noComment => 'Без комментария';

  @override
  String loadingReviewsError(String error) {
    return 'Ошибка загрузки отзывов: $error';
  }

  @override
  String get upcoming => 'Предстоящие';

  @override
  String get past => 'Прошедшие';

  @override
  String get noTitle => 'Без названия';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get approved => 'Одобрено';

  @override
  String get pending => 'Ожидает';

  @override
  String get rejected => 'Отклонено';

  @override
  String get attended => 'Посещено';

  @override
  String get missed => 'Пропущено';

  @override
  String get leaveReview => 'Оставить отзыв →';

  @override
  String get leaveReviewTitle => 'Оставить отзыв';

  @override
  String rateEvent(String title) {
    return 'Оцените мероприятие \"$title\"';
  }

  @override
  String get shareImpression => 'Поделитесь впечатлениями (необязательно)';

  @override
  String get send => 'Отправить';

  @override
  String get thankYouForReview => 'Спасибо за ваш отзыв!';

  @override
  String error(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get onModeration => 'На модерации';

  @override
  String get newInitiative => 'Новое дело';

  @override
  String get notificationSettings => 'Настройки уведомлений';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get newEvents => 'Новые мероприятия';

  @override
  String get newEventsSubtitle => 'По вашим категориям';

  @override
  String get invitationsFromNGO => 'Приглашения от НКО';

  @override
  String get invitationsSubtitle => 'Когда организация вас приглашает';

  @override
  String get newReviews => 'Новые отзывы';

  @override
  String get newReviewsSubtitle => 'Когда НКО оставляет отзыв';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get eventReminders => 'Напоминания о событиях';

  @override
  String get eventRemindersSubtitle => 'За 24 часа до начала';

  @override
  String get languageSettings => 'Язык / Тил';

  @override
  String get russian => 'Русский';

  @override
  String get russianNative => 'Russian';

  @override
  String get kyrgyz => 'Кыргызча';

  @override
  String get kyrgyzNative => 'Kyrgyz';

  @override
  String get homeMenu => 'Главная';

  @override
  String get mapMenu => 'Карта';

  @override
  String get talentsMenu => 'Таланты';

  @override
  String get profileMenu => 'Профиль';

  @override
  String get createWhatTitle => 'Что хотите создать?';

  @override
  String get createWhatSubtitle => 'Выберите тип активности';

  @override
  String get createEventTitle => 'Мероприятие';

  @override
  String get createEventSubtitle =>
      'Для НКО и организаторов — официальные события с записью';

  @override
  String get createInitiativeTitle => 'Доброе дело';

  @override
  String get createInitiativeSubtitle =>
      'Для жителей сел и городов — локальная помощь без НКО';

  @override
  String get talentsOnlyOrganizers => 'доступно только для организаторов';

  @override
  String get talentRadarOnlyForOrganizers =>
      'Радар талантов доступен только аккаунтам организаторов.';

  @override
  String get talentRadarTitle => 'Радар талантов';

  @override
  String get talentRadarSubtitle =>
      'Найдите лучших волонтеров для вашего проекта';

  @override
  String talentFoundCount(int count) {
    return 'Найдено: $count лучших волонтеров';
  }

  @override
  String get talentSearchHint => 'Поиск по имени...';

  @override
  String get talentMinRating => 'Мин. рейтинг:';

  @override
  String get talentCity => 'Город:';

  @override
  String get talentSkill => 'Навык:';

  @override
  String talentRadius(int km) {
    return 'Радиус: $km км';
  }

  @override
  String get talentResetFilters => 'Сбросить фильтры';

  @override
  String get invite => 'Пригласить';

  @override
  String invitePerson(String name) {
    return 'Пригласить $name';
  }

  @override
  String get chooseEventForInvite => 'Выберите мероприятие для приглашения:';

  @override
  String get noEventsForInvite =>
      'У вас пока нет активных мероприятий для приглашения.';

  @override
  String get inviteProjectTitle => 'Приглашение на проект!';

  @override
  String inviteProjectBody(String eventTitle) {
    return 'Организация приглашает вас на мероприятие \"$eventTitle\".';
  }

  @override
  String get inviteSentSuccess => '✅ Приглашение успешно отправлено!';

  @override
  String inviteSendError(String error) {
    return 'Ошибка отправки: $error';
  }

  @override
  String get sendInvite => 'Отправить приглашение';

  @override
  String get orgShort => 'НКО';

  @override
  String get cityOsh => 'Ош';

  @override
  String get cityKarakol => 'Каракол';

  @override
  String get cityNaryn => 'Нарын';

  @override
  String get cityJalalAbad => 'Джалал-Абад';

  @override
  String get skillMedicine => 'Медицина';

  @override
  String get skillPedagogy => 'Педагогика';

  @override
  String get skillConstruction => 'Строительство';

  @override
  String get skillPhotography => 'Фотография';

  @override
  String get categoryEcology => 'Экология';

  @override
  String get categoryEducation => 'Образование';

  @override
  String get categoryHealth => 'Здоровье';

  @override
  String get categorySocial => 'Соц. помощь';

  @override
  String get categoryAnimals => 'Животные';

  @override
  String get categoryCulture => 'Культура';

  @override
  String get categorySport => 'Спорт';

  @override
  String get categoryOther => 'Другое';

  @override
  String get kyrgyzstan => 'Кыргызстан';

  @override
  String get bishkek => 'Бишкек';

  @override
  String get loading => 'Загрузка...';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get add => 'Добавить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get done => 'Готово';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get ok => 'ОК';

  @override
  String get close => 'Закрыть';

  @override
  String get exportPdf => 'Экспорт PDF';

  @override
  String get noEntriesYet => 'Пока нет записей';

  @override
  String get dateLabel => 'Дата';

  @override
  String get activityLabel => 'Активность';

  @override
  String get hoursLabel => 'Часы';

  @override
  String get statusLabel => 'Статус';

  @override
  String get recentlyViewed => 'Недавно просмотренные';

  @override
  String get onboardingWelcome => 'Добро пожаловать в Ыктыярчы';

  @override
  String get onboardingStep1 =>
      'Находите мероприятия на карте и в ленте — фильтры и поиск помогут быстрее.';

  @override
  String get onboardingStep2 =>
      'Записывайтесь одним нажатием и следите за местами в событии.';

  @override
  String get onboardingStep3 =>
      'Напоминания и история просмотров держат вас в курсе.';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String shareEventSubject(String title) {
    return 'Мероприятие: $title';
  }

  @override
  String shareEventBody(String title, String detail) {
    return '$title\n\n$detail';
  }

  @override
  String get mapQuickFiltersHint => 'Быстрые фильтры';

  @override
  String get loadingMore => 'Ещё загрузка...';
}
