// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kirghiz Kyrgyz (`ky`).
class AppLocalizationsKy extends AppLocalizations {
  AppLocalizationsKy([String locale = 'ky']) : super(locale);

  @override
  String get appName => 'Ыктыярчы';

  @override
  String get appTagline => 'Кыргызстандын ыктыярчылар платформасы';

  @override
  String get volunteersCount => 'Ыктыярчылар';

  @override
  String get organizationsCount => 'Уюмдар';

  @override
  String get eventsCount => 'Иш-чаралар';

  @override
  String get createAccount => 'Аккаунт түзүү';

  @override
  String get loginToAccount => 'Аккаунтка кирүү';

  @override
  String get joinGoodDeeds => 'Жакшы иштерге кошулуңуз';

  @override
  String get login => 'Аккаунтка кирүү';

  @override
  String get loginSubtitle => 'Улантуу үчүн кириңиз';

  @override
  String get usernameOrEmail => 'Username же Email';

  @override
  String get password => 'Сыр сөз';

  @override
  String get forgotPassword => 'Сыр сөздү унуттуңузбу?';

  @override
  String get loginButton => 'Кирүү';

  @override
  String get noAccount => 'Аккаунт жокпу? ';

  @override
  String get registerLink => 'Катталуу';

  @override
  String get register => 'Катталуу';

  @override
  String get registerSubtitle => 'Ыктыярчы аккаунтун түзүңүз';

  @override
  String get accountType => 'Аккаунт түрү';

  @override
  String get volunteer => 'Ыктыярчы';

  @override
  String get ngo => 'КУУ';

  @override
  String get firstName => 'Аты *';

  @override
  String get lastName => 'Фамилиясы *';

  @override
  String get username => 'Username *';

  @override
  String get email => 'Email *';

  @override
  String get phone => 'Телефон (милдеттүү эмес)';

  @override
  String get passwordConfirm => 'Сыр сөздү ырастаңыз *';

  @override
  String get passwordHint => 'Кеминде 8 белги';

  @override
  String get repeatPassword => 'Сыр сөздү кайталаңыз';

  @override
  String get agreeWith => 'Мен макулмун ';

  @override
  String get termsOfService => 'Колдонуу шарттары';

  @override
  String get and => ' жана ';

  @override
  String get privacyPolicy => 'Купуялык саясаты';

  @override
  String get registerButton => 'Катталуу';

  @override
  String get haveAccount => 'Аккаунт барбы? ';

  @override
  String get loginLink => 'Кирүү';

  @override
  String get fillAllFields => 'Бардык талааларды толтуруңуз';

  @override
  String get fillAllRequiredFields => 'Бардык милдеттүү талааларды толтуруңуз';

  @override
  String get agreeToTermsRequired =>
      'Колдонуу шарттары жана купуялык саясаты менен макулдашуу керек';

  @override
  String get passwordsDoNotMatch => 'Сыр сөздөр дал келбейт';

  @override
  String get passwordMinLength => 'Сыр сөз кеминде 8 белгиден турушу керек';

  @override
  String hello(String name) {
    return 'Салам, $name!';
  }

  @override
  String get hours => 'саат';

  @override
  String get badges => 'белгилер';

  @override
  String get rating => 'рейтинг';

  @override
  String get searchPlaceholder => 'Бүгүн кайда жардам бере алам?';

  @override
  String get nearby => 'Жакында';

  @override
  String get today => 'Бүгүн';

  @override
  String get urgent => 'Шашылыш';

  @override
  String get categories => 'Категориялар';

  @override
  String loadingError(String error) {
    return 'Жүктөө катасы: $error';
  }

  @override
  String get retry => 'Кайталоо';

  @override
  String get noEventsFound => 'Иш-чаралар табылган жок';

  @override
  String get noEventsSubtitle =>
      'Фильтрлерди же издөө сурамын өзгөртүп көрүңүз';

  @override
  String get filters => 'Фильтрлер';

  @override
  String get filtersSubtitle => 'Издөө натыйжаларын тактаңыз';

  @override
  String get format => 'Формат';

  @override
  String get all => 'Баары';

  @override
  String get offline => 'Жеринде';

  @override
  String get online => 'Онлайн форматта';

  @override
  String get urgentOnly => 'Шашылыш гана';

  @override
  String get urgentOnlySubtitle => 'Шашылыш иш-чараларды гана көрсөтүү';

  @override
  String get reset => 'Тазалоо';

  @override
  String get apply => 'Колдонуу';

  @override
  String get tomorrow => 'Эртең';

  @override
  String participantsOf(int current, int total) {
    return '$current / $total катышуучу';
  }

  @override
  String get myActivity => 'Менин активдүүлүгүм';

  @override
  String get myEvents => 'Менин иш-чараларым';

  @override
  String get myEventsSubtitle => 'Катышуулар';

  @override
  String get myInitiatives => 'Менин демилгелерим';

  @override
  String get myInitiativesSubtitle => 'Жакшы иштер';

  @override
  String get achievements => 'Жетишкендиктер';

  @override
  String achievementsReceived(int count) {
    return '$count алынды';
  }

  @override
  String get settings => 'Жөндөөлөр';

  @override
  String get editProfile => 'Профилди өзгөртүү';

  @override
  String get editProfileSubtitle => 'Сүрөт, АФА, жайгашкан жер';

  @override
  String get notifications => 'Билдирмелер';

  @override
  String get notificationsSubtitle => 'Push-билдирмелердин жөндөөлөрү';

  @override
  String get language => 'Тил';

  @override
  String get languageRussian => 'Орусча';

  @override
  String get aboutApp => 'Тиркеме жөнүндө';

  @override
  String get privacyPolicyTitle => 'Купуялык саясаты';

  @override
  String get privacyPolicySubtitle => 'Маалыматтарыңызды кантип коргойбуз';

  @override
  String get termsOfServiceTitle => 'Колдонуу шарттары';

  @override
  String get termsOfServiceSubtitle => 'Эрежелер жана макулдашуулар';

  @override
  String get logout => 'Аккаунттан чыгуу';

  @override
  String get volunteerBook => 'Ыктыярчынын электрондук китепчеси';

  @override
  String confirmedHours(int hours) {
    return '$hours ырасталган саат';
  }

  @override
  String get open => 'Ачуу';

  @override
  String get allAchievements => 'Баары';

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked / $total алынды';
  }

  @override
  String get reviewsFromOrganizations => 'Уюмдардан пикирлер';

  @override
  String get allReviews => 'Баары';

  @override
  String daysAgo(int days) {
    return '$days күн мурун';
  }

  @override
  String monthsAgo(int months) {
    return '$months ай мурун';
  }

  @override
  String get todayLabel => 'Бүгүн';

  @override
  String get received => '✓ Алынды';

  @override
  String get ngoProfileTitle => 'КУУ профили';

  @override
  String get orgNameLabel => 'Уюмдун аталышы *';

  @override
  String get verifiedStatus => 'Тастыкталган макам';

  @override
  String get notVerifiedStatus => 'Тастыкталган эмес';

  @override
  String get ngoEventsListTitle => 'Иш-чаралар тизмеси';

  @override
  String get ngoNoEvents => 'Бул уюмда азырынча иш-чара жок';

  @override
  String get ngoNoDescription => 'Сүрөттөмө жок';

  @override
  String ngoEventsCount(int count) {
    return '$count иш-чара';
  }

  @override
  String get reviews => 'Пикирлер';

  @override
  String get guest => 'Конок';

  @override
  String get organizationRating => 'уюмдун рейтинги';

  @override
  String projectsCountShort(int count) {
    return '$count долбоор';
  }

  @override
  String volunteersCountShort(int count) {
    return '$count ыктыярчы';
  }

  @override
  String distanceKm(String distance) {
    return '$distance км';
  }

  @override
  String registeredCount(int count) {
    return '$count катталды';
  }

  @override
  String hoursShort(int hours) {
    return '$hours с';
  }

  @override
  String todayAt(String time) {
    return 'Бүгүн саат $time';
  }

  @override
  String spotsAvailable(int count) {
    return '✓ $count орун бар';
  }

  @override
  String get noSpots => '✗ Орун жок';

  @override
  String get loginToRegister => 'Катталуу үчүн аккаунтка кириңиз';

  @override
  String get registeredSuccess => 'Сиз катталдыңыз! Ийгилик';

  @override
  String get registerFailed =>
      'Катталуу ишке ашкан жок. Кийин кайра аракет кылыңыз.';

  @override
  String get manage => 'Башкаруу';

  @override
  String get management => 'Башкаруу';

  @override
  String get registered => 'Сиз катталгансыз';

  @override
  String get dateAndTime => 'Күнү жана убактысы';

  @override
  String get eventLocation => 'Өткөрүлүүчү жер';

  @override
  String get showOnMap => 'Картадан көрсөтүү';

  @override
  String get participants => 'Катышуучулар';

  @override
  String get volunteerHoursLabel => 'Ыктыярчы сааттары';

  @override
  String hoursWillBeCredited(int hours) {
    return '$hours саат эсептелет';
  }

  @override
  String get descriptionLabel => 'Сүрөттөмө';

  @override
  String get requirementsLabel => 'Талаптар';

  @override
  String get titleLabel => 'Аталышы';

  @override
  String get eventTitleHint => 'Мисалы: Паркта ишембилик';

  @override
  String get eventDescriptionHint => 'Иш-чараны кеңири сүрөттөп бериңиз...';

  @override
  String get eventLocationHint => 'Даректи киргизиңиз же GPS басыңыз';

  @override
  String get hoursLabelShort => 'Саат';

  @override
  String get spotsLabel => 'Орун';

  @override
  String get publishEvent => 'Иш-чараны жарыялоо';

  @override
  String get eventCreatedSuccess => 'Иш-чара ийгиликтүү түзүлдү!';

  @override
  String get eventCreateFailed => 'Иш-чараны түзүү мүмкүн болгон жок';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get added => 'Кошулду';

  @override
  String photoNumber(int number) {
    return '$number-сүрөт';
  }

  @override
  String get sendForReview => 'Текшерүүгө жөнөтүү';

  @override
  String get initiativeAddBeforeAfterPhotos =>
      'Кеминде бир ДО жана ПОСЛЕ сүрөтүн кошуңуз';

  @override
  String get initiativeNeedGps => 'Адегенде GPS жайгашкан жерди аныктаңыз';

  @override
  String get initiativeSentForModeration =>
      'Демилге модерацияга жөнөтүлдү. Сааттар текшерүүдөн кийин эсептелет.';

  @override
  String get initiativeInfoBanner =>
      'Алыскы аймактар үчүн негизги механизм. Демилге тастыктоодон мурда модерациядан өтөт.';

  @override
  String get initiativeTitleHint => 'Мисалы: Дарыя жээгин тазалоо';

  @override
  String get initiativeDescriptionHint => 'Жакшы ишиңизди сүрөттөп бериңиз...';

  @override
  String initiativeGpsCaptured(String lat, String lng) {
    return 'GPS аныкталды: $lat, $lng';
  }

  @override
  String get initiativeResolveGps => 'Менин жайгашкан жеримди аныктоо (GPS)';

  @override
  String get liveCamera => 'Live-камера';

  @override
  String get liveCameraDescription =>
      'Реалдуу убакытта сүрөткө тартуу үчүн күйгүзүңүз. Бул жасалмалоо тобокелин азайтат.';

  @override
  String get initiativeModerationPending => 'Модерация абалы: текшерүүдө';

  @override
  String get initiativeModerationDraft =>
      'Модерация абалы: черновик, али жөнөтүлгөн жок';

  @override
  String initiativeBeforePhotos(int count) {
    return 'ДО сүрөттөрү ($count/3)';
  }

  @override
  String initiativeAfterPhotos(int count) {
    return 'ПОСЛЕ сүрөттөрү ($count/3)';
  }

  @override
  String get initiativeSuccess => 'Демилге ийгиликтүү жөнөтүлдү';

  @override
  String get submitting => 'Жөнөтүлүүдө...';

  @override
  String get notificationsMarkedRead => 'Бардык билдирмелер окулду';

  @override
  String get readAllNotifications => 'Баарын окуу';

  @override
  String get noNotifications => 'Билдирмелер жок';

  @override
  String get noNotificationsSubtitle =>
      'Жаңы билдирмелер чыкканда бул жерде көрүнөт';

  @override
  String get justNow => 'азыр эле';

  @override
  String get newSkill => 'Жаңы көндүм';

  @override
  String get skillExampleHint => 'Мисалы: Дизайн';

  @override
  String get profileUpdatedSuccess => 'Профиль ийгиликтүү жаңыртылды!';

  @override
  String get savingError => 'Сактоо катасы';

  @override
  String get mainInformation => 'Негизги маалымат';

  @override
  String get firstNameLabel => 'Аты';

  @override
  String get lastNameLabel => 'Фамилиясы';

  @override
  String get locationLabel => 'Жайгашкан жери';

  @override
  String get aboutMeLabel => 'Мен жөнүндө';

  @override
  String get skillsSection => 'Көндүмдөр';

  @override
  String enterField(String field) {
    return '$field киргизиңиз';
  }

  @override
  String get offlineScheduleLoaded =>
      'Катталган иш-чаралардын кэштелген графиги көрсөтүлдү (offline режим).';

  @override
  String cachedDataFrom(int day, int month, int year) {
    return 'Маалымат $day.$month.$year күнүнөн';
  }

  @override
  String get searchOnMapPlaceholder => 'Картадан издөө';

  @override
  String onMapCount(int count) {
    return 'Картада: $count';
  }

  @override
  String get findingYou => 'Сизди издеп жатабыз...';

  @override
  String get eventFallbackTitle => 'Иш-чара';

  @override
  String get emailVerificationTitle => 'Email ырастоо';

  @override
  String get emailVerificationSubtitle =>
      'Каттан келген 6 орундуу кодду киргизиңиз';

  @override
  String get verifyEmailButton => 'Email ырастоо';

  @override
  String get resendCode => 'Кодду кайра жөнөтүү';

  @override
  String get verificationCodeInvalid => 'Туура 6 орундуу кодду киргизиңиз';

  @override
  String get emailVerifiedSuccess => 'Email ийгиликтүү ырасталды';

  @override
  String get verificationFailed => 'Email ырастоодо ката кетти';

  @override
  String get verificationCodeResent => 'Ырастоо коду кайра жөнөтүлдү';

  @override
  String get verificationResendFailed =>
      'Кодду кайра жөнөтүү мүмкүн болгон жок';

  @override
  String get whatsappAuthButton => 'WhatsApp аркылуу кирүү';

  @override
  String get whatsappLoginTitle => 'WhatsApp аркылуу авторизация';

  @override
  String get whatsappLoginSubtitle =>
      'Телефон номериңизди киргизип, WhatsApp\'ка OTP код алыңыз';

  @override
  String get whatsappPhoneRequired => 'Телефон номерин киргизиңиз';

  @override
  String get sendCodeWhatsApp => 'Кодду WhatsApp\'ка жөнөтүү';

  @override
  String get whatsappCodeSent => 'Код WhatsApp\'ка жөнөтүлдү';

  @override
  String get whatsappCodeSendFailed =>
      'WhatsApp кодун жөнөтүү мүмкүн болгон жок';

  @override
  String get whatsappVerifyButton => 'Кодду ырастоо';

  @override
  String get enterVerificationCode => 'Ырастоо кодун киргизиңиз';

  @override
  String reviewsCount(int count) {
    return '$count пикир';
  }

  @override
  String get anonymous => 'Аноним';

  @override
  String hoursAgo(int hours) {
    return '$hours саат мурун';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes мүн. мурун';
  }

  @override
  String get noComment => 'Комментарийсиз';

  @override
  String loadingReviewsError(String error) {
    return 'Пикирлерди жүктөө катасы: $error';
  }

  @override
  String get upcoming => 'Келечектеги';

  @override
  String get past => 'Өткөн';

  @override
  String get noTitle => 'Аталышсыз';

  @override
  String get notSpecified => 'Көрсөтүлгөн эмес';

  @override
  String get approved => 'Бекитилди';

  @override
  String get pending => 'Күтүүдө';

  @override
  String get rejected => 'Четке кагылды';

  @override
  String get attended => 'Катышты';

  @override
  String get missed => 'Катышкан жок';

  @override
  String get leaveReview => 'Пикир калтыруу →';

  @override
  String get leaveReviewTitle => 'Пикир калтыруу';

  @override
  String rateEvent(String title) {
    return '\"$title\" иш-чарасын баалаңыз';
  }

  @override
  String get shareImpression =>
      'Таасирлериңиз менен бөлүшүңүз (милдеттүү эмес)';

  @override
  String get send => 'Жөнөтүү';

  @override
  String get thankYouForReview => 'Пикириңиз үчүн рахмат!';

  @override
  String error(String error) {
    return 'Ката: $error';
  }

  @override
  String get onModeration => 'Модерацияда';

  @override
  String get newInitiative => 'Жаңы иш';

  @override
  String get notificationSettings => 'Билдирмелердин жөндөөлөрү';

  @override
  String get pushNotifications => 'Push-билдирмелер';

  @override
  String get newEvents => 'Жаңы иш-чаралар';

  @override
  String get newEventsSubtitle => 'Сиздин категорияларыңыз боюнча';

  @override
  String get invitationsFromNGO => 'КУУдан чакыруулар';

  @override
  String get invitationsSubtitle => 'Уюм сизди чакырганда';

  @override
  String get newReviews => 'Жаңы пикирлер';

  @override
  String get newReviewsSubtitle => 'КУУ пикир калтырганда';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get eventReminders => 'Окуялар жөнүндө эскертмелер';

  @override
  String get eventRemindersSubtitle => 'Башталышына 24 саат калганда';

  @override
  String get languageSettings => 'Язык / Тил';

  @override
  String get russian => 'Орусча';

  @override
  String get russianNative => 'Russian';

  @override
  String get kyrgyz => 'Кыргызча';

  @override
  String get kyrgyzNative => 'Kyrgyz';

  @override
  String get homeMenu => 'Башкы';

  @override
  String get mapMenu => 'Карта';

  @override
  String get talentsMenu => 'Таланттар';

  @override
  String get profileMenu => 'Профиль';

  @override
  String get createWhatTitle => 'Эмне түзгүңүз келет?';

  @override
  String get createWhatSubtitle => 'Активдүүлүктүн түрүн тандаңыз';

  @override
  String get createEventTitle => 'Иш-чара';

  @override
  String get createEventSubtitle =>
      'КУУ жана уюштуруучулар үчүн — катталуучу расмий окуялар';

  @override
  String get createInitiativeTitle => 'Жакшы иш';

  @override
  String get createInitiativeSubtitle =>
      'Шаар жана айыл тургундары үчүн — КУУсуз жергиликтүү жардам';

  @override
  String get talentsOnlyOrganizers => 'уюштуруучулар үчүн гана жеткиликтүү';

  @override
  String get talentRadarOnlyForOrganizers =>
      'Таланттар радары уюштуруучу аккаунттар үчүн гана жеткиликтүү.';

  @override
  String get talentRadarTitle => 'Таланттар радары';

  @override
  String get talentRadarSubtitle =>
      'Долбооруңуз үчүн мыкты ыктыярчыларды табыңыз';

  @override
  String talentFoundCount(int count) {
    return 'Табылды: $count мыкты ыктыярчы';
  }

  @override
  String get talentSearchHint => 'Аты боюнча издөө...';

  @override
  String get talentMinRating => 'Мин. рейтинг:';

  @override
  String get talentCity => 'Шаар:';

  @override
  String get talentSkill => 'Көндүм:';

  @override
  String talentRadius(int km) {
    return 'Радиус: $km км';
  }

  @override
  String get talentResetFilters => 'Фильтрлерди тазалоо';

  @override
  String get invite => 'Чакыруу';

  @override
  String invitePerson(String name) {
    return '$name чакыруу';
  }

  @override
  String get chooseEventForInvite => 'Чакыруу үчүн иш-чараны тандаңыз:';

  @override
  String get noEventsForInvite =>
      'Азырынча чакыруу үчүн активдүү иш-чараларыңыз жок.';

  @override
  String get inviteProjectTitle => 'Долбоорго чакыруу!';

  @override
  String inviteProjectBody(String eventTitle) {
    return 'Уюм сизди \"$eventTitle\" иш-чарасына чакырат.';
  }

  @override
  String get inviteSentSuccess => '✅ Чакыруу ийгиликтүү жөнөтүлдү!';

  @override
  String inviteSendError(String error) {
    return 'Жөнөтүү катасы: $error';
  }

  @override
  String get sendInvite => 'Чакыруу жөнөтүү';

  @override
  String get orgShort => 'КУУ';

  @override
  String get cityOsh => 'Ош';

  @override
  String get cityKarakol => 'Каракол';

  @override
  String get cityNaryn => 'Нарын';

  @override
  String get cityJalalAbad => 'Жалал-Абад';

  @override
  String get skillMedicine => 'Медицина';

  @override
  String get skillPedagogy => 'Педагогика';

  @override
  String get skillConstruction => 'Курулуш';

  @override
  String get skillPhotography => 'Сүрөткө тартуу';

  @override
  String get categoryEcology => 'Экология';

  @override
  String get categoryEducation => 'Билим берүү';

  @override
  String get categoryHealth => 'Саламаттык';

  @override
  String get categorySocial => 'Соц. жардам';

  @override
  String get categoryAnimals => 'Жаныбарлар';

  @override
  String get categoryCulture => 'Маданият';

  @override
  String get categorySport => 'Спорт';

  @override
  String get categoryOther => 'Башка';

  @override
  String get kyrgyzstan => 'Кыргызстан';

  @override
  String get bishkek => 'Бишкек';

  @override
  String get loading => 'Жүктөлүүдө...';

  @override
  String get save => 'Сактоо';

  @override
  String get cancel => 'Жокко чыгаруу';

  @override
  String get add => 'Кошуу';

  @override
  String get delete => 'Өчүрүү';

  @override
  String get edit => 'Өзгөртүү';

  @override
  String get back => 'Артка';

  @override
  String get next => 'Кийинки';

  @override
  String get done => 'Даяр';

  @override
  String get yes => 'Ооба';

  @override
  String get no => 'Жок';

  @override
  String get ok => 'Макул';

  @override
  String get close => 'Жабуу';

  @override
  String get exportPdf => 'PDF экспорт';

  @override
  String get noEntriesYet => 'Азырынча жазуулар жок';

  @override
  String get dateLabel => 'Дата';

  @override
  String get activityLabel => 'Активдүүлүк';

  @override
  String get hoursLabel => 'Саат';

  @override
  String get statusLabel => 'Статус';

  @override
  String get recentlyViewed => 'Жакында көрүлгөн';

  @override
  String get onboardingWelcome => 'Ыктыярчыга кош келиңиз';

  @override
  String get onboardingStep1 =>
      'Окуяларды картада жана тизмеден табыңыз — фильтр менен издөө тезирээк жардам берет.';

  @override
  String get onboardingStep2 =>
      'Бир баскыч менен катталыңыз жана орундарды ээрчиңиз.';

  @override
  String get onboardingStep3 =>
      'Эскертүүлөр жана көрүү тарыхы сизди кабардар кармайт.';

  @override
  String get onboardingGetStarted => 'Баштоо';

  @override
  String shareEventSubject(String title) {
    return 'Окуя: $title';
  }

  @override
  String shareEventBody(String title, String detail) {
    return '$title\n\n$detail';
  }

  @override
  String get mapQuickFiltersHint => 'Тез фильтрлер';

  @override
  String get loadingMore => 'Дагы жүктөлүүдө...';
}
