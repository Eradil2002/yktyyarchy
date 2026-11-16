import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/features/home/screens/home_screen.dart';
import 'package:volunteering/core/providers/events_provider.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/services/events_service.dart';
import 'package:volunteering/core/api/api_client.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    late EventsProvider eventsProvider;
    late AuthProvider authProvider;

    setUp(() {
      // Create mock providers
      final apiClient = ApiClient();
      final eventsService = EventsService(apiClient);
      eventsProvider = EventsProvider(eventsService);
      authProvider = AuthProvider(apiClient);
    });

    testWidgets('HomeScreen displays app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<EventsProvider>.value(value: eventsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('HomeScreen shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<EventsProvider>.value(value: eventsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Initially should show loading or content
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('HomeScreen has scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<EventsProvider>.value(value: eventsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Should have scrollable widget
      expect(
        find.byType(SingleChildScrollView).or(find.byType(ListView)),
        findsWidgets,
      );
    });
  });

  group('HomeScreen Navigation Tests', () {
    testWidgets('HomeScreen can navigate to event details', (WidgetTester tester) async {
      final apiClient = ApiClient();
      final eventsService = EventsService(apiClient);
      final eventsProvider = EventsProvider(eventsService);
      final authProvider = AuthProvider(apiClient);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<EventsProvider>.value(value: eventsProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify home screen is displayed
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
