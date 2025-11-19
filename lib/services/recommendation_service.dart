import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/recommendation.dart';
import '../models/mood_entry.dart';
import '../config/api_config.dart';

class RecommendationService extends ChangeNotifier {
  List<Recommendation> _recommendations = [];
  List<Recommendation> get recommendations => _recommendations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fetch personalized recommendations based on mood
  Future<void> fetchRecommendations(MoodEntry? mood, Map<String, dynamic> userProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendations = [];

      // Fetch from multiple sources in parallel
      await Future.wait([
        _fetchMovies(mood),
        _fetchBooks(mood),
        _fetchVideos(mood),
        _fetchTherapists(userProfile),
        _fetchMusicPlaylists(mood),
        _fetchAffirmations(),
        _fetchNutritionTips(mood),
      ]);

      // Sort by relevance score
      _recommendations.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch movies from TMDB API
  Future<void> _fetchMovies(MoodEntry? mood) async {
    try {
      final genre = _getMoodBasedGenre(mood);
      final url = Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?api_key=${ApiConfig.tmdbApiKey}&with_genres=$genre&sort_by=popularity.desc',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;

        for (var movie in movies.take(3)) {
          _recommendations.add(Recommendation(
            id: movie['id'].toString(),
            type: RecommendationType.movie,
            title: movie['title'],
            description: movie['overview'],
            imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
            actionUrl: 'https://www.themoviedb.org/movie/${movie['id']}',
            relevanceScore: movie['vote_average'].toDouble(),
            metadata: {
              'rating': movie['vote_average'],
              'release_date': movie['release_date'],
            },
          ));
        }
      }
    } catch (e) {
      debugPrint('Error fetching movies: $e');
    }
  }

  // Fetch books from Google Books API
  Future<void> _fetchBooks(MoodEntry? mood) async {
    try {
      final query = _getMoodBasedBookQuery(mood);
      final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=3&key=${ApiConfig.googleBooksApiKey}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final books = data['items'] as List? ?? [];

        for (var book in books) {
          final volumeInfo = book['volumeInfo'];
          _recommendations.add(Recommendation(
            id: book['id'],
            type: RecommendationType.book,
            title: volumeInfo['title'],
            subtitle: (volumeInfo['authors'] as List?)?.join(', '),
            description: volumeInfo['description'],
            imageUrl: volumeInfo['imageLinks']?['thumbnail'],
            actionUrl: volumeInfo['infoLink'],
            relevanceScore: 7.5,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error fetching books: $e');
    }
  }

  // Fetch YouTube videos
  Future<void> _fetchVideos(MoodEntry? mood) async {
    try {
      final query = _getMoodBasedVideoQuery(mood);
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&maxResults=3&key=${ApiConfig.youtubeApiKey}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videos = data['items'] as List? ?? [];

        for (var video in videos) {
          final snippet = video['snippet'];
          _recommendations.add(Recommendation(
            id: video['id']['videoId'],
            type: RecommendationType.video,
            title: snippet['title'],
            description: snippet['description'],
            imageUrl: snippet['thumbnails']['high']['url'],
            actionUrl: 'https://www.youtube.com/watch?v=${video['id']['videoId']}',
            relevanceScore: 8.0,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
    }
  }

  // Fetch local therapists from Yelp API
  Future<void> _fetchTherapists(Map<String, dynamic> userProfile) async {
    try {
      final location = userProfile['location'] ?? 'New York, NY';
      final url = Uri.parse(
        'https://api.yelp.com/v3/businesses/search?term=therapist&location=$location&limit=3',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${ApiConfig.yelpApiKey}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final businesses = data['businesses'] as List? ?? [];

        for (var business in businesses) {
          _recommendations.add(Recommendation(
            id: business['id'],
            type: RecommendationType.therapist,
            title: business['name'],
            subtitle: business['location']['address1'],
            description: 'Rating: ${business['rating']} ⭐ (${business['review_count']} reviews)',
            imageUrl: business['image_url'],
            actionUrl: business['url'],
            relevanceScore: business['rating'].toDouble(),
            metadata: {
              'phone': business['phone'],
              'distance': business['distance'],
              'price': business['price'] ?? '',
            },
          ));
        }
      }
    } catch (e) {
      debugPrint('Error fetching therapists: $e');
    }
  }

  // Fetch music playlists (Apple Music or Spotify)
  Future<void> _fetchMusicPlaylists(MoodEntry? mood) async {
    try {
      // TODO: Implement Apple Music API integration
      // For now, add curated playlists
      final playlists = _getCuratedPlaylists(mood);
      _recommendations.addAll(playlists);
    } catch (e) {
      debugPrint('Error fetching music: $e');
    }
  }

  // Fetch daily affirmations
  Future<void> _fetchAffirmations() async {
    try {
      final url = Uri.parse('https://www.affirmations.dev/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _recommendations.add(Recommendation(
          id: 'affirmation_${DateTime.now().millisecondsSinceEpoch}',
          type: RecommendationType.affirmation,
          title: 'Daily Affirmation',
          description: data['affirmation'],
          relevanceScore: 9.0,
        ));
      }
    } catch (e) {
      debugPrint('Error fetching affirmations: $e');
      // Fallback to local affirmations
      _recommendations.add(Recommendation(
        id: 'affirmation_local',
        type: RecommendationType.affirmation,
        title: 'Daily Affirmation',
        description: 'You are capable of amazing things. Believe in yourself.',
        relevanceScore: 9.0,
      ));
    }
  }

  // Fetch nutrition tips
  Future<void> _fetchNutritionTips(MoodEntry? mood) async {
    final tips = _getMoodBasedNutritionTips(mood);
    _recommendations.add(tips);
  }

  // Helper: Get movie genre based on mood
  String _getMoodBasedGenre(MoodEntry? mood) {
    if (mood == null) return '35'; // Comedy by default

    switch (mood.mood) {
      case MoodType.sad:
      case MoodType.verySad:
        return '35'; // Comedy
      case MoodType.anxious:
      case MoodType.stressed:
        return '18'; // Drama
      case MoodType.happy:
      case MoodType.veryHappy:
        return '12'; // Adventure
      case MoodType.calm:
        return '99'; // Documentary
      default:
        return '35'; // Comedy
    }
  }

  // Helper: Get book query based on mood
  String _getMoodBasedBookQuery(MoodEntry? mood) {
    if (mood == null) return 'self-help wellness';

    switch (mood.mood) {
      case MoodType.anxious:
        return 'anxiety relief mindfulness';
      case MoodType.stressed:
        return 'stress management meditation';
      case MoodType.sad:
        return 'inspirational uplifting';
      default:
        return 'wellness self-improvement';
    }
  }

  // Helper: Get video query based on mood
  String _getMoodBasedVideoQuery(MoodEntry? mood) {
    if (mood == null) return 'meditation relaxation';

    switch (mood.mood) {
      case MoodType.anxious:
        return 'calming meditation anxiety relief';
      case MoodType.stressed:
        return 'stress relief breathing exercise';
      case MoodType.sad:
        return 'motivational uplifting';
      case MoodType.tired:
        return 'energizing morning yoga';
      default:
        return 'guided meditation mindfulness';
    }
  }

  // Helper: Get curated playlists based on mood
  List<Recommendation> _getCuratedPlaylists(MoodEntry? mood) {
    // Curated playlist recommendations
    return [
      Recommendation(
        id: 'playlist_1',
        type: RecommendationType.music,
        title: 'Peaceful Piano',
        description: 'Relax and unwind with beautiful piano pieces',
        imageUrl: 'https://via.placeholder.com/300',
        relevanceScore: 8.5,
      ),
    ];
  }

  // Helper: Get nutrition tips based on mood
  Recommendation _getMoodBasedNutritionTips(MoodEntry? mood) {
    String tip = 'Stay hydrated and eat balanced meals for optimal wellness';

    if (mood != null) {
      switch (mood.mood) {
        case MoodType.anxious:
          tip = 'Try chamomile tea and foods rich in omega-3s to help reduce anxiety';
          break;
        case MoodType.tired:
          tip = 'Boost energy with protein-rich breakfast and stay hydrated';
          break;
        case MoodType.stressed:
          tip = 'Reduce caffeine and try foods rich in magnesium like nuts and seeds';
          break;
        default:
          break;
      }
    }

    return Recommendation(
      id: 'nutrition_tip',
      type: RecommendationType.nutrition,
      title: 'Nutrition Tip',
      description: tip,
      relevanceScore: 7.0,
    );
  }
}

