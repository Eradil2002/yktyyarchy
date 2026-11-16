import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volunteering/features/events/widgets/event_card.dart';
import 'package:volunteering/core/models/event.dart';

void main() {
  group('EventCard Widget Tests', () {
    late Event testEvent;

    setUp(() {
      testEvent = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        category: 'ecology',
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'Bishkek',
        hours: 4,
        spotsTotal: 20,
        spotsBooked: 5,
        organizerName: 'Test NGO',
        status: 'open',
        type: 'offline',
      );
    });

    testWidgets('EventCard displays event information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCard(event: testEvent),
          ),
        ),
      );

      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Test NGO'), findsOneWidget);
      expect(find.text('Bishkek'), findsOneWidget);
    });

    testWidgets('EventCard shows urgent badge when event is urgent', (WidgetTester tester) async {
      final urgentEvent = testEvent.copyWith(isUrgent: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCard(event: urgentEvent),
          ),
        ),
      );

      expect(find.text('СРОЧНО'), findsOneWidget);
    });

    testWidgets('EventCard is tappable', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCard(
              event: testEvent,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EventCard));
      expect(tapped, isTrue);
    });
  });
}
