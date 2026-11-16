import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volunteering/firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:volunteering/core/services/user_lists_service.dart';
import 'package:volunteering/core/widgets/fade_page_route.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/core/services/auth_service.dart';
import 'package:volunteering/core/services/users_service.dart';
import 'package:volunteering/core/services/events_service.dart';
import 'package:volunteering/core/services/notification_service.dart';
import 'package:volunteering/core/services/notifications_service.dart';
import 'package:volunteering/core/services/initiatives_service.dart';
import 'package:volunteering/core/providers/notifications_provider.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/providers/events_provider.dart';
import 'package:volunteering/core/providers/initiatives_provider.dart';
import 'package:volunteering/core/providers/locale_provider.dart';

// Feature screens
import 'package:volunteering/features/welcome/screens/welcome_screen.dart';
import 'package:volunteering/features/auth/screens/login_screen.dart';
import 'package:volunteering/features/auth/screens/whatsapp_login_screen.dart';
import 'package:volunteering/features/auth/screens/register_screen.dart';
import 'package:volunteering/features/auth/screens/email_verification_screen.dart';
import 'package:volunteering/features/home/screens/main_shell.dart';
import 'package:volunteering/features/events/screens/event_detail_screen.dart';
import 'package:volunteering/features/notifications/screens/notifications_screen.dart';
import 'package:volunteering/features/profile/screens/achievements_screen.dart';
import 'package:volunteering/features/reviews/screens/reviews_screen.dart';
import 'package:volunteering/features/events/screens/my_events_screen.dart';
import 'package:volunteering/features/initiatives/screens/my_initiatives_screen.dart';
import 'package:volunteering/features/profile/screens/edit_profile_screen.dart';
import 'package:volunteering/features/profile/screens/ngo_profile_screen.dart';
import 'package:volunteering/features/profile/screens/volunteer_book_screen.dart';
import 'package:volunteering/features/talents/screens/volunteer_profile_screen.dart';
import 'package:volunteering/features/notifications/screens/notification_settings_screen.dart';
import 'package:volunteering/features/profile/screens/language_settings_screen.dart';
import 'package:volunteering/features/legal/screens/privacy_policy_screen.dart';
import 'package:volunteering/features/legal/screens/terms_of_service_screen.dart';

import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/core/utils/debug_i18n_logger.dart';
import 'package:volunteering/data/models/models.dart';

// Performance & Code Splitting (#89, #90)
import 'package:volunteering/core/services/performance_service.dart';
import 'package:volunteering/web_deferred_routes.dart' as deferred_routes;

// Global flag to track Firebase availability
bool isFirebaseAvailable = false;

class AppDependencies {
  final ApiClient apiClient;
  final AuthService authService;
  final UsersService usersService;
  final EventsService eventsService;
  final InitiativesService initiativesService;
  final NotificationService pushService;
  final NotificationsService notificationsService;

  AppDependencies._({
    required this.apiClient,
    required this.authService,
    required this.usersService,
    required this.eventsService,
    required this.initiativesService,
    required this.pushService,
    required this.notificationsService,
  });

  factory AppDependencies.create() {
    final apiClient = ApiClient();
    return AppDependencies._(
      apiClient: apiClient,
      authService: AuthService(apiClient),
      usersService: UsersService(apiClient),
      eventsService: EventsService(apiClient),
      initiativesService: InitiativesService(apiClient),
      pushService: NotificationService(apiClient),
      notificationsService: NotificationsService(apiClient),
    );
  }
}

void main() async {
  // Preserve splash screen while initializing
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Performance Monitoring (#90)
  await AppPerformance.init();

  // Try to initialize Firebase, but don't crash if it fails
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseAvailable = true;
    debugPrint('✓ Firebase initialized successfully');
  } catch (e) {
    isFirebaseAvailable = false;
    debugPrint('⚠ Firebase initialization failed: $e');
  }

  // Initialize date formatting for supported locales
  await Future.wait([
    initializeDateFormatting('ru', null),
    initializeDateFormatting('ky', null),
  ]);

  await Hive.initFlutter();
  await Hive.openBox<dynamic>('user_lists');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final dependencies = AppDependencies.create();

  // Wrap with Sentry for error reporting (#90)
  await sentryInit(
    dsn: const String.fromEnvironment('SENTRY_DSN'),
    appRunner: () async => runApp(VolunteeringApp(dependencies: dependencies)),
  );
}

class VolunteeringApp extends StatefulWidget {
  final AppDependencies dependencies;

  const VolunteeringApp({super.key, required this.dependencies});

  @override
  State<VolunteeringApp> createState() => _VolunteeringAppState();
}

class _VolunteeringAppState extends State<VolunteeringApp> {
  @override
  void initState() {
    super.initState();
    // Remove splash screen after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: widget.dependencies.apiClient),
        Provider<AuthService>.value(value: widget.dependencies.authService),
        Provider<UsersService>.value(value: widget.dependencies.usersService),
        Provider<EventsService>.value(value: widget.dependencies.eventsService),
        Provider<InitiativesService>.value(value: widget.dependencies.initiativesService),
        Provider<NotificationService>.value(value: widget.dependencies.pushService),
        Provider<NotificationsService>.value(value: widget.dependencies.notificationsService),
        ChangeNotifierProvider(
          create: (_) {
            final provider = AuthProvider(
              widget.dependencies.authService,
              widget.dependencies.usersService,
              widget.dependencies.pushService,
            );
            widget.dependencies.pushService.initialize(); // Initialize once
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(widget.dependencies.notificationsService),
        ),
        ChangeNotifierProvider(
          create: (_) => EventsProvider(widget.dependencies.eventsService),
        ),
        ChangeNotifierProvider(
          create: (_) => InitiativesProvider(widget.dependencies.initiativesService),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserListsService(),
        ),
      ],
      child: Consumer2<AuthProvider, LocaleProvider>(
        builder: (context, authProvider, localeProvider, _) {
          return MaterialApp(
            title: 'Ыктыярчы — Волонтеры Кыргызстана',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: authProvider.isLoading
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : authProvider.isAuthenticated
                    ? const MainShell()
                    : const WelcomeScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/welcome':
                  return MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                    settings: settings,
                  );
                case '/login':
                  return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                    settings: settings,
                  );
                case '/login-whatsapp':
                  return MaterialPageRoute(
                    builder: (_) => const WhatsAppLoginScreen(),
                    settings: settings,
                  );
                case '/register':
                  return MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                    settings: settings,
                  );
                case '/verify-email':
                  return MaterialPageRoute(
                    builder: (_) => const EmailVerificationScreen(),
                    settings: settings,
                  );
                case '/home':
                  return MaterialPageRoute(
                    builder: (_) => const MainShell(),
                    settings: settings,
                  );
                case '/map':
                  return MaterialPageRoute(
                    builder: (_) => const MainShell(initialIndex: 1),
                    settings: settings,
                  );
                case '/notifications':
                  return MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                    settings: settings,
                  );
                case '/achievements':
                  return MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                    settings: settings,
                  );
                case '/reviews':
                  return MaterialPageRoute(
                    builder: (_) => const ReviewsScreen(),
                    settings: settings,
                  );
                case '/my-events':
                  return MaterialPageRoute(
                    builder: (_) => const MyEventsScreen(),
                    settings: settings,
                  );
                case '/my-initiatives':
                  return MaterialPageRoute(
                    builder: (_) => const MyInitiativesScreen(),
                    settings: settings,
                  );
                case '/edit-profile':
                  // Use Code Splitting (#89)
                  return deferred_routes.editProfileRoute(settings);
                case '/volunteer-book':
                  // Use Code Splitting (#89)
                  return deferred_routes.volunteerBookRoute(settings);
                case '/notification-settings':
                  return MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                    settings: settings,
                  );
                case '/language':
                  return MaterialPageRoute(
                    builder: (_) => const LanguageSettingsScreen(),
                    settings: settings,
                  );
                case '/privacy-policy':
                  return MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                    settings: settings,
                  );
                case '/terms-of-service':
                  return MaterialPageRoute(
                    builder: (_) => const TermsOfServiceScreen(),
                    settings: settings,
                  );
                case '/event-detail':
                  final event = settings.arguments as VolunteerEvent?;
                  if (event == null) return null;
                  return FadePageRoute<void>(
                    builder: (_) => EventDetailScreen(event: event),
                    settings: settings,
                  );
                case '/create-event':
                  // Use Code Splitting (#89)
                  return deferred_routes.createEventRoute(settings);
                case '/create-initiative':
                  // Use Code Splitting (#89)
                  return deferred_routes.createInitiativeRoute(settings);
                case '/volunteer-profile':
                  final volunteer = settings.arguments as VolunteerUser?;
                  if (volunteer == null) return null;
                  return MaterialPageRoute(
                    builder: (_) => VolunteerProfileScreen(volunteer: volunteer),
                    settings: settings,
                  );
                case '/ngo-profile':
                  // For Web, this could also be split, but for now we follow the plan items 84-90
                  final args = settings.arguments as Map<String, dynamic>?;
                  if (args == null) return null;
                  final organizationId = args['organizationId']?.toString();
                  if (organizationId == null || organizationId.isEmpty) return null;
                  return MaterialPageRoute(
                    builder: (_) => NgoProfileScreen(
                      organizationId: organizationId,
                      initialName: (args['initialName'] ?? '').toString(),
                      initialVerified: args['initialVerified'] == true,
                      initialRating: (args['initialRating'] as num?)?.toDouble() ?? 0,
                    ),
                    settings: settings,
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
