import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:volunteering/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Tests', () {
    testWidgets('App launches and shows home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check if home screen elements are present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Navigate through bottom navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on Events tab
      await tester.tap(find.byIcon(Icons.event));
      await tester.pumpAndSettle();

      // Tap on Map tab
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();

      // Tap on Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
    });

    testWidgets('Search for events', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap search field
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField.first);
        await tester.pumpAndSettle();

        // Enter search query
        await tester.enterText(searchField.first, 'ecology');
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('View event details', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find first event card and tap it
      final eventCards = find.byType(Card);
      if (eventCards.evaluate().isNotEmpty) {
        await tester.tap(eventCards.first);
        await tester.pumpAndSettle();

        // Verify detail screen opened
        expect(find.byType(AppBar), findsWidgets);
      }
    });
  });
}
