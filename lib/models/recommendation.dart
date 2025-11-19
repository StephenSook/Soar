enum RecommendationType {
  movie,
  book,
  video,
  therapist,
  meditation,
  journalPrompt,
  music,
  affirmation,
  workout,
  nutrition,
  event,
}

class Recommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? actionUrl;
  final Map<String, dynamic> metadata;
  final double relevanceScore;
  final List<String> tags;

  Recommendation({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.actionUrl,
    this.metadata = const {},
    this.relevanceScore = 0.0,
    this.tags = const [],
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      type: RecommendationType.values.byName(json['type']),
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      metadata: json['metadata'] ?? {},
      relevanceScore: json['relevanceScore']?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'metadata': metadata,
      'relevanceScore': relevanceScore,
      'tags': tags,
    };
  }

  String get typeIcon {
    switch (type) {
      case RecommendationType.movie:
        return '🎬';
      case RecommendationType.book:
        return '📚';
      case RecommendationType.video:
        return '📹';
      case RecommendationType.therapist:
        return '👨‍⚕️';
      case RecommendationType.meditation:
        return '🧘';
      case RecommendationType.journalPrompt:
        return '✍️';
      case RecommendationType.music:
        return '🎵';
      case RecommendationType.affirmation:
        return '💭';
      case RecommendationType.workout:
        return '💪';
      case RecommendationType.nutrition:
        return '🥗';
      case RecommendationType.event:
        return '📅';
    }
  }
}

