import 'package:flutter_test/flutter_test.dart';
import 'package:volunteering/data/models/models.dart';

void main() {
  group('VolunteerUser Model Tests', () {
    test('fromJson creates valid user from complete JSON', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'first_name': 'John',
        'last_name': 'Doe',
        'location': 'Bishkek',
        'role': 'volunteer',
        'total_hours': 50,
        'rating': 4.5,
        'is_verified': true,
        'volunteer_profile': {
          'bio': 'Passionate volunteer',
          'skills': ['Teaching', 'IT'],
        },
      };

      final user = VolunteerUser.fromJson(json);

      expect(user.id, '123');
      expect(user.username, 'testuser');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.name, 'John Doe');
      expect(user.location, 'Bishkek');
      expect(user.role, 'volunteer');
      expect(user.totalHours, 50);
      expect(user.rating, 4.5);
      expect(user.isVerified, true);
      expect(user.bio, 'Passionate volunteer');
      expect(user.skills, ['Teaching', 'IT']);
    });

    test('fromJson handles minimal JSON', () {
      final json = {
        'id': '456',
        'username': 'minimaluser',
      };

      final user = VolunteerUser.fromJson(json);

      expect(user.id, '456');
      expect(user.username, 'minimaluser');
      expect(user.name, 'minimaluser');
      expect(user.location, 'Not specified');
      expect(user.totalHours, 0);
      expect(user.rating, 0.0);
      expect(user.isVerified, false);
    });

    test('fromJson handles NGO profile', () {
      final json = {
        'id': '789',
        'username': 'ngouser',
        'role': 'ngo',
        'ngo_profile': {
          'org_name': 'Green NGO',
          'description': 'Environmental organization',
          'contact_email': 'contact@greenngo.kg',
          'website': 'https://greenngo.kg',
        },
      };

      final user = VolunteerUser.fromJson(json);

      expect(user.role, 'ngo');
      expect(user.isOrganizer, true);
      expect(user.orgName, 'Green NGO');
      expect(user.orgDescription, 'Environmental organization');
      expect(user.orgEmail, 'contact@greenngo.kg');
      expect(user.orgWebsite, 'https://greenngo.kg');
    });

    test('isOrganizer returns true for NGO role', () {
      final user = VolunteerUser(
        id: '1',
        name: 'Test',
        location: 'Test',
        role: 'ngo',
      );

      expect(user.isOrganizer, true);
    });

    test('isOrganizer returns false for volunteer role', () {
      final user = VolunteerUser(
        id: '1',
        name: 'Test',
        location: 'Test',
        role: 'volunteer',
      );

      expect(user.isOrganizer, false);
    });

    test('mock user has valid data', () {
      final mockUser = VolunteerUser.mock;

      expect(mockUser.id, isNotEmpty);
      expect(mockUser.name, isNotEmpty);
      expect(mockUser.totalHours, greaterThan(0));
      expect(mockUser.rating, greaterThan(0));
    });
  });

  group('Initiative Model Tests', () {
    test('fromJson creates valid initiative', () {
      final json = {
        'id': 1,
        'title': 'Clean City Initiative',
        'description': 'Monthly city cleanup',
        'category': 'ecology',
        'start_date': '2026-05-01T00:00:00Z',
        'end_date': '2026-12-31T23:59:59Z',
        'organizer_details': {
          'first_name': 'Green',
          'is_verified': true,
        },
      };

      final initiative = Initiative.fromJson(json);

      expect(initiative.id, 1);
      expect(initiative.title, 'Clean City Initiative');
      expect(initiative.description, 'Monthly city cleanup');
      expect(initiative.categoryId, 'ecology');
      expect(initiative.organizerName, 'Green');
      expect(initiative.organizerVerified, true);
    });

    test('fromJson handles minimal data', () {
      final json = {
        'id': 2,
        'title': 'Test Initiative',
      };

      final initiative = Initiative.fromJson(json);

      expect(initiative.id, 2);
      expect(initiative.title, 'Test Initiative');
      expect(initiative.description, isEmpty);
    });
  });

  group('Achievement Model Tests', () {
    test('fromJson creates valid achievement', () {
      final json = {
        'id': 1,
        'title': 'First Event',
        'description': 'Attended first volunteer event',
        'icon': 'star',
        'earned_at': '2026-04-01T10:00:00Z',
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.id, 1);
      expect(achievement.title, 'First Event');
      expect(achievement.description, 'Attended first volunteer event');
      expect(achievement.icon, 'star');
      expect(achievement.earnedAt, isNotNull);
    });

    test('mockList returns non-empty list', () {
      final achievements = Achievement.mockList;

      expect(achievements, isNotEmpty);
      expect(achievements.first, isA<Achievement>());
    });
  });

  group('UserReview Model Tests', () {
    test('fromJson creates valid review', () {
      final json = {
        'id': 1,
        'rating': 5,
        'comment': 'Great event!',
        'reviewer_name': 'John Doe',
        'created_at': '2026-04-15T12:00:00Z',
      };

      final review = UserReview.fromJson(json);

      expect(review.id, 1);
      expect(review.rating, 5);
      expect(review.comment, 'Great event!');
      expect(review.reviewerName, 'John Doe');
    });

    test('mockList returns non-empty list', () {
      final reviews = UserReview.mockList;

      expect(reviews, isNotEmpty);
      expect(reviews.first, isA<UserReview>());
    });
  });
}
