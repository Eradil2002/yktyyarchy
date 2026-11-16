import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:volunteering/core/services/events_service.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/data/models/models.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([ApiClient, Dio])
import 'events_service_test.mocks.dart';

void main() {
  late EventsService eventsService;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(mockApiClient.dio).thenReturn(mockDio);
    eventsService = EventsService(mockApiClient);
  });

  group('EventsService Tests', () {
    test('getEvents returns success with data', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'results': [
            {
              'id': 1,
              'title': 'Test Event',
              'date': '2026-05-01T10:00:00Z',
              'location': 'Bishkek',
              'category': 'ecology',
              'type': 'offline',
              'spots_total': 20,
              'spots_booked': 5,
              'hours': 4,
              'organizer_details': {
                'first_name': 'Test Organizer',
                'is_verified': true,
              },
            }
          ],
          'next': null,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/events/'),
      );

      when(mockDio.get(
        '/events/',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await eventsService.getEvents();

      // Assert
      expect(result['success'], true);
      expect(result['data'], isNotNull);
      expect(result['data']['results'], isA<List>());
      expect(result['data']['results'].length, 1);
    });

    test('getEvents handles network error', () async {
      // Arrange
      when(mockDio.get(
        '/events/',
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/events/'),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act
      final result = await eventsService.getEvents();

      // Assert
      expect(result['success'], false);
      expect(result['error'], isNotNull);
    });

    test('getEvents with filters passes correct parameters', () async {
      // Arrange
      final mockResponse = Response(
        data: {'results': [], 'next': null},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/events/'),
      );

      when(mockDio.get(
        '/events/',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await eventsService.getEvents(
        category: 'ecology',
        type: 'offline',
        isUrgent: true,
        page: 2,
      );

      // Assert
      verify(mockDio.get(
        '/events/',
        queryParameters: argThat(
          allOf([
            containsPair('category', 'ecology'),
            containsPair('type', 'offline'),
            containsPair('is_urgent', true),
            containsPair('page', 2),
          ]),
          named: 'queryParameters',
        ),
      )).called(1);
    });

    test('getEvents returns 404 error', () async {
      // Arrange
      when(mockDio.get(
        '/events/',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'detail': 'Not found'},
            statusCode: 404,
            requestOptions: RequestOptions(path: '/events/'),
          ));

      // Act
      final result = await eventsService.getEvents();

      // Assert
      expect(result['success'], false);
    });
  });

  group('EventsService Pagination Tests', () {
    test('getEventsPage returns EventsPageResult', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'results': [
            {
              'id': 1,
              'title': 'Event 1',
              'date': '2026-05-01T10:00:00Z',
              'organizer_details': {'first_name': 'Org'},
            }
          ],
          'next': 'http://api.example.com/events/?page=2',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/events/'),
      );

      when(mockDio.get(
        '/events/',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await eventsService.getEventsPage();

      // Assert
      expect(result.events, isA<List<VolunteerEvent>>());
      expect(result.events.length, 1);
      expect(result.hasMore, true);
    });

    test('getEventsPage with no next page', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'results': [],
          'next': null,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/events/'),
      );

      when(mockDio.get(
        '/events/',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await eventsService.getEventsPage();

      // Assert
      expect(result.hasMore, false);
    });
  });
}
