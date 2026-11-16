// Data models for the Volunteering app

class VolunteerUser {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String name;
  final String? avatarUrl;
  final String location;
  final String role;
  final String bio;
  final int totalHours;
  final double rating;
  final int reviewCount;
  final int eventsCount;
  final int badgesCount;
  final List<String> skills;
  final bool isVerified;
  final Map<String, dynamic>? ngoProfile;

  const VolunteerUser({
    required this.id,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    required this.name,
    this.avatarUrl,
    required this.location,
    this.role = 'volunteer',
    this.bio = '',
    this.totalHours = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.eventsCount = 0,
    this.badgesCount = 0,
    this.skills = const [],
    this.isVerified = false,
    this.ngoProfile,
  });

  factory VolunteerUser.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    final volProfile = json['volunteer_profile'] as Map<String, dynamic>?;
    final rawSkills = volProfile?['skills'];
    final parsedSkills = rawSkills is List ? List<String>.from(rawSkills) : <String>[];

    return VolunteerUser(
      id: json['id']?.toString() ?? '',
      username: (json['username'] ?? '').toString(),
      firstName: firstName.toString(),
      lastName: lastName.toString(),
      name: fullName.isNotEmpty ? fullName : (json['username'] ?? 'Unknown user'),
      avatarUrl: json['avatar'],
      location: json['location'] ?? 'Not specified',
      role: (json['role'] ?? 'volunteer').toString(),
      bio: (volProfile?['bio'] ?? '').toString(),
      totalHours: json['total_hours'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: 0, 
      eventsCount: 0, 
      badgesCount: 0, 
      skills: parsedSkills,
      isVerified: json['is_verified'] ?? false,
      ngoProfile: json['ngo_profile'] is Map ? Map<String, dynamic>.from(json['ngo_profile']) : null,
    );
  }

  String get orgName => ngoProfile?['org_name']?.toString() ?? name;
  String get orgDescription => ngoProfile?['description']?.toString() ?? bio;
  String get orgEmail => ngoProfile?['contact_email']?.toString() ?? '';
  String get orgWebsite => ngoProfile?['website']?.toString() ?? '';

  static VolunteerUser get mock => const VolunteerUser(
        id: '1',
        name: 'Sample Volunteer',
        location: 'Sample City',
        totalHours: 48,
        rating: 4.8,
        reviewCount: 12,
        eventsCount: 15,
        badgesCount: 5,
        skills: ['Mentoring', 'IT', 'Environment'],
        isVerified: true,
      );

  bool get isOrganizer =>
      role == 'ngo' || role == 'organization' || role == 'organizer';
}

class NGOOrganization {
  final String id;
  final String name;
  final String? logoUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final int activeEvents;
  final int totalVolunteers;
  final bool isVerified;
  final String contactEmail;
  final String? contactPhone;

  const NGOOrganization({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.description,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.activeEvents = 0,
    this.totalVolunteers = 0,
    this.isVerified = false,
    required this.contactEmail,
    this.contactPhone,
  });

  static List<NGOOrganization> get mockList => [
        const NGOOrganization(
          id: '1',
          name: 'Green Initiative',
          description: 'Community group focused on local environment activities.',
          rating: 4.7,
          reviewCount: 89,
          activeEvents: 3,
          totalVolunteers: 245,
          isVerified: true,
          contactEmail: 'eco@kg.org',
        ),
        const NGOOrganization(
          id: '2',
          name: 'Human Aid Network',
          description: 'Humanitarian organization supporting emergency response and donor events.',
          rating: 4.9,
          reviewCount: 156,
          activeEvents: 5,
          totalVolunteers: 512,
          isVerified: true,
          contactEmail: 'info@redcrescent.kg',
        ),
      ];
}

enum EventType { online, offline }
enum EventStatus { open, closed, completed }

class VolunteerEvent {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final String organizerName;
  final bool organizerVerified;
  final double organizerRating;
  final String categoryId;
  final DateTime date;
  final String? endTime;
  final String location;
  final EventType type;
  final int hours;
  final int spotsTotal;
  final int spotsBooked;
  final List<String> requirements;
  final EventStatus status;
  final bool isUrgent;
  final double? distanceKm;
  final double? latitude;
  final double? longitude;
  final bool isRegistered;
  final String? imageUrl;

  const VolunteerEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    this.organizerVerified = false,
    this.organizerRating = 0,
    required this.categoryId,
    required this.date,
    this.endTime,
    required this.location,
    required this.type,
    required this.hours,
    required this.spotsTotal,
    this.spotsBooked = 0,
    this.requirements = const [],
    this.status = EventStatus.open,
    this.isUrgent = false,
    this.isRegistered = false,
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  factory VolunteerEvent.fromJson(Map<String, dynamic> json) {
    return VolunteerEvent(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      organizerId: json['organizer']?.toString() ?? '',
      organizerName: json['organizer_details']?['first_name'] ?? 'Organizer',
      organizerVerified: json['organizer_details']?['is_verified'] ?? false,
      organizerRating: (json['organizer_details']?['rating'] ?? 0.0).toDouble(),
      categoryId: json['category'] ?? 'other',
      date: DateTime.parse(json['date']),
      endTime: json['end_time'],
      location: json['location'] ?? '',
      type: json['type'] == 'online' ? EventType.online : EventType.offline,
      hours: json['hours'] ?? 0,
      spotsTotal: json['spots_total'] ?? 0,
      spotsBooked: json['spots_booked'] ?? 0,
      requirements: List<String>.from(json['requirements'] ?? []),
      status: _parseStatus(json['status']),
      isUrgent: json['is_urgent'] ?? false,
      isRegistered: json['is_registered'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['image'],
    );
  }

  static EventStatus _parseStatus(String? status) {
    switch (status) {
      case 'open': return EventStatus.open;
      case 'closed': return EventStatus.closed;
      case 'completed': return EventStatus.completed;
      default: return EventStatus.open;
    }
  }

  bool get hasSpots => spotsBooked < spotsTotal;
  int get spotsLeft => spotsTotal - spotsBooked;

  static List<VolunteerEvent> get mockList => [];
}

class UserReview {
  final String id;
  final String reviewerName;
  final String? reviewerAvatar;
  final double rating;
  final String text;
  final DateTime date;
  final String eventTitle;
  final bool isFromNGO;

  const UserReview({
    required this.id,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    required this.text,
    required this.date,
    required this.eventTitle,
    this.isFromNGO = false,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: (json['id'] ?? '').toString(),
      reviewerName: (json['reviewer_name'] ?? json['author'] ?? 'Аноним').toString(),
      reviewerAvatar: json['reviewer_avatar']?.toString(),
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      text: (json['text'] ?? json['content'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? json['created_at'] ?? '').toString()) ?? DateTime.now(),
      eventTitle: (json['event_title'] ?? json['event'] ?? 'Мероприятие').toString(),
      isFromNGO: json['is_from_ngo'] == true || (json['reviewer_type'] == 'ngo'),
    );
  }

  static List<UserReview> get mockList => [];
}

class Initiative {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final String categoryId;
  final String location;
  final DateTime date;
  final int hours;
  final List<String> beforePhotos;
  final List<String> afterPhotos;
  final bool isApproved;
  final String status;

  const Initiative({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.categoryId,
    required this.location,
    required this.date,
    required this.hours,
    this.beforePhotos = const [],
    this.afterPhotos = const [],
    this.isApproved = false,
    this.status = 'pending',
  });

  factory Initiative.fromJson(Map<String, dynamic> json) {
    final before = json['before_photos'];
    final after = json['after_photos'];
    final rawDate = (json['date'] ?? json['created_at'] ?? '').toString();
    return Initiative(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      authorId: (json['creator'] ?? json['author'] ?? '').toString(),
      authorName: (json['creator_name'] ?? json['author_name'] ?? '').toString(),
      categoryId: (json['category'] ?? 'other').toString(),
      location: (json['location'] ?? '').toString(),
      date: DateTime.tryParse(rawDate) ?? DateTime.now(),
      hours: (json['hours'] as num?)?.toInt() ?? 0,
      beforePhotos: before is List ? before.map((e) => e.toString()).toList() : const [],
      afterPhotos: after is List ? after.map((e) => e.toString()).toList() : const [],
      isApproved: (json['status'] ?? '').toString() == 'approved' || json['is_approved'] == true,
      status: (json['status'] ?? 'pending').toString(),
    );
  }

  static List<Initiative> get mockList => [];
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String? iconPath;
  final String? emoji; // Keep for fallback
  final bool isUnlocked;
  final int progress;
  final int total;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.iconPath,
    this.emoji,
    this.isUnlocked = false,
    this.progress = 0,
    required this.total,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      iconPath: json['icon_path']?.toString(),
      emoji: json['emoji']?.toString(),
      isUnlocked: json['is_unlocked'] == true,
      progress: ((json['progress'] ?? 0) as num).toInt(),
      total: ((json['total'] ?? 1) as num).toInt(),
    );
  }

  static List<Achievement> get mockList => [];
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  bool isRead;
  final String type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    required this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    final rawDate = json['created_at'] ?? json['date'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return AppNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      date: parsedDate,
      isRead: json['is_read'] == true,
      type: (json['type'] ?? 'system').toString(),
    );
  }

  static List<AppNotification> get mockList => [];
}
