import 'package:cloud_firestore/cloud_firestore.dart';

/// Journal Entry Model
/// 
/// Represents a user's journal entry with optional mood association
class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime timestamp;
  final String? moodType; // Optional: link to mood at time of writing
  final List<String> tags;
  final bool isFavorite;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
    this.moodType,
    this.tags = const [],
    this.isFavorite = false,
  });

  /// Create from Firestore document
  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      moodType: data['moodType'],
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'moodType': moodType,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  /// Create a copy with modified fields
  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? timestamp,
    String? moodType,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      moodType: moodType ?? this.moodType,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Journaling Prompt
/// 
/// Categorized prompts to inspire journaling based on mood or theme
class JournalingPrompt {
  final String id;
  final String prompt;
  final String category; // gratitude, anxiety, self-esteem, general, etc.
  final List<String> relatedMoods; // Which moods this prompt works well for

  const JournalingPrompt({
    required this.id,
    required this.prompt,
    required this.category,
    this.relatedMoods = const [],
  });
}

