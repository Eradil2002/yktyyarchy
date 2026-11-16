import 'package:flutter_test/flutter_test.dart';
import 'package:volunteering/data/models/models.dart';

void main() {
  group('VolunteerUser.fromJson', () {
    test('builds full name and reads profile', () {
      final u = VolunteerUser.fromJson({
        'id': 7,
        'username': 'aibek',
        'first_name': 'Айбек',
        'last_name': 'Токтогулов',
        'role': 'volunteer',
        'location': 'Бишкек',
        'volunteer_profile': {'bio': 'hi', 'skills': ['first-aid']},
      });
      expect(u.id, '7');
      expect(u.name, 'Айбек Токтогулов');
      expect(u.skills, ['first-aid']);
      expect(u.bio, 'hi');
    });

    test('falls back to username when name is empty', () {
      final u = VolunteerUser.fromJson({'id': 1, 'username': 'eco_kg', 'role': 'ngo'});
      expect(u.name, 'eco_kg');
      expect(u.role, 'ngo');
      expect(u.location, 'Not specified');
    });
  });

  group('VolunteerEvent.fromJson', () {
    final json = {
      'id': 14,
      'title': 'Уборка парка',
      'description': 'd',
      'organizer': 21,
      'organizer_details': {'first_name': 'Эко', 'is_verified': true, 'rating': 4.5},
      'category': 'ecology',
      'date': '2026-12-01T10:00:00Z',
      'location': 'Бишкек',
      'type': 'online',
      'hours': 3,
      'spots_total': 10,
      'spots_booked': 4,
      'status': 'completed',
      'is_urgent': true,
    };

    test('parses fields and enums', () {
      final e = VolunteerEvent.fromJson(json);
      expect(e.id, '14');
      expect(e.organizerName, 'Эко');
      expect(e.organizerVerified, isTrue);
      expect(e.type, EventType.online);
      expect(e.status, EventStatus.completed);
      expect(e.isUrgent, isTrue);
    });

    test('computes free spots', () {
      final e = VolunteerEvent.fromJson(json);
      expect(e.hasSpots, isTrue);
      expect(e.spotsLeft, 6);
    });
  });

  test('UserReview.fromJson reads text and NGO flag', () {
    final r = UserReview.fromJson({
      'id': 3,
      'reviewer_name': 'Гульнара',
      'rating': 5,
      'text': 'Отлично',
      'created_at': '2026-11-01T00:00:00Z',
      'is_from_ngo': true,
    });
    expect(r.text, 'Отлично');
    expect(r.rating, 5.0);
    expect(r.isFromNGO, isTrue);
  });
}
