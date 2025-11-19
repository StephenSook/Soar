import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
  anxious,
  stressed,
  calm,
  energetic,
  tired,
}

class MoodEntry {
  final String id;
  final String userId;
  final DateTime timestamp;
  final MoodType mood;
  final int moodRating; // 1-5 scale
  final String? journalNote;
  final String? detectedSentiment; // From ML analysis
  final List<String> tags;
  final Map<String, dynamic>? context; // Location, weather, etc.

  MoodEntry({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.mood,
    required this.moodRating,
    this.journalNote,
    this.detectedSentiment,
    this.tags = const [],
    this.context,
  });

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      userId: data['userId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      mood: MoodType.values.byName(data['mood']),
      moodRating: data['moodRating'],
      journalNote: data['journalNote'],
      detectedSentiment: data['detectedSentiment'],
      tags: List<String>.from(data['tags'] ?? []),
      context: data['context'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'mood': mood.name,
      'moodRating': moodRating,
      'journalNote': journalNote,
      'detectedSentiment': detectedSentiment,
      'tags': tags,
      'context': context,
    };
  }

  String get moodEmoji {
    switch (mood) {
      case MoodType.veryHappy:
        return '😄';
      case MoodType.happy:
        return '😊';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😔';
      case MoodType.verySad:
        return '😢';
      case MoodType.anxious:
        return '😰';
      case MoodType.stressed:
        return '😫';
      case MoodType.calm:
        return '😌';
      case MoodType.energetic:
        return '⚡';
      case MoodType.tired:
        return '😴';
    }
  }

  String get moodLabel {
    switch (mood) {
      case MoodType.veryHappy:
        return 'Very Happy';
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.verySad:
        return 'Very Sad';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.stressed:
        return 'Stressed';
      case MoodType.calm:
        return 'Calm';
      case MoodType.energetic:
        return 'Energetic';
      case MoodType.tired:
        return 'Tired';
    }
  }
}

