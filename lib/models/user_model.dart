import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int? age;
  final List<String> interests;
  final List<String> mentalHealthHistory;
  final Map<String, bool> contentPreferences;
  final String? moodCheckInTime;
  final List<String> blockedApps;
  final DateTime createdAt;
  final DateTime? lastMoodCheckIn;
  final String? timezone;
  final String? communityAlias;
  final List<String> joinedGroups;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.age,
    this.interests = const [],
    this.mentalHealthHistory = const [],
    this.contentPreferences = const {},
    this.moodCheckInTime,
    this.blockedApps = const [],
    required this.createdAt,
    this.lastMoodCheckIn,
    this.timezone,
    this.communityAlias,
    this.joinedGroups = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      age: data['age'],
      interests: List<String>.from(data['interests'] ?? []),
      mentalHealthHistory: List<String>.from(data['mentalHealthHistory'] ?? []),
      contentPreferences: Map<String, bool>.from(data['contentPreferences'] ?? {}),
      moodCheckInTime: data['moodCheckInTime'],
      blockedApps: List<String>.from(data['blockedApps'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMoodCheckIn: data['lastMoodCheckIn'] != null 
          ? (data['lastMoodCheckIn'] as Timestamp).toDate() 
          : null,
      timezone: data['timezone'],
      communityAlias: data['communityAlias'],
      joinedGroups: List<String>.from(data['joinedGroups'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'age': age,
      'interests': interests,
      'mentalHealthHistory': mentalHealthHistory,
      'contentPreferences': contentPreferences,
      'moodCheckInTime': moodCheckInTime,
      'blockedApps': blockedApps,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMoodCheckIn': lastMoodCheckIn != null 
          ? Timestamp.fromDate(lastMoodCheckIn!) 
          : null,
      'timezone': timezone,
      'communityAlias': communityAlias,
      'joinedGroups': joinedGroups,
    };
  }
}

