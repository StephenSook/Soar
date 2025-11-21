import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/recommendation.dart';
import '../models/mood_entry.dart';
import '../config/api_config.dart';

/// Service for fetching personalized recommendations from various APIs.
/// 
/// Image availability by API:
/// - Movies (TMDB): ✅ Always provides poster images via poster_path
/// - Books (Google Books): ⚠️ May or may not have imageLinks (some books lack covers)
/// - Videos (YouTube): ✅ Always provides thumbnails via thumbnails object
/// - Therapists (Yelp): ⚠️ Usually provides image_url, but some businesses may not have images
/// - Music: ❌ No API integration (uses curated playlists with Unsplash images)
/// - Affirmations: ❌ API doesn't provide images (uses Unsplash fallback images)
/// - Nutrition: ❌ No API (uses Unsplash fallback images)
class RecommendationService extends ChangeNotifier {
  List<Recommendation> _recommendations = [];
  List<Recommendation> get recommendations => _recommendations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fetch personalized recommendations based on mood and user preferences
  Future<void> fetchRecommendations(MoodEntry? mood, Map<String, dynamic> userProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendations = [];

      // Extract user preferences for personalization
      final interests = (userProfile['interests'] as List?)?.cast<String>() ?? [];
      final mentalHealthAreas = (userProfile['mentalHealthHistory'] as List?)?.cast<String>() ?? [];
      final contentPreferences = (userProfile['contentPreferences'] as Map?)?.cast<String, bool>() ?? {};

      // Fetch from multiple sources based on content preferences
      final futures = <Future>[];

      // Only fetch content types that the user has enabled
      if (contentPreferences['videos'] != false) {
        futures.add(_fetchMovies(mood, interests, mentalHealthAreas, page: 1));
      }
      if (contentPreferences['articles'] != false) {
        futures.add(_fetchBooks(mood, interests, mentalHealthAreas));
      }
      if (contentPreferences['videos'] != false) {
        futures.add(_fetchVideos(mood, interests, mentalHealthAreas));
      }
      
      // Always fetch therapists and affirmations
      futures.add(_fetchTherapists(userProfile));
      futures.add(_fetchAffirmations());
      
      if (contentPreferences['meditation'] != false || interests.contains('meditation')) {
        futures.add(_fetchMusicPlaylists(mood));
      }
      
      futures.add(_fetchNutritionTips(mood, interests));

      await Future.wait(futures);

      // Boost relevance scores for content matching user interests
      _boostRelevanceByInterests(interests, mentalHealthAreas);

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

  // Regenerate recommendations for a specific type
  Future<void> regenerateRecommendations(
    RecommendationType type,
    MoodEntry? mood,
    Map<String, dynamic> userProfile,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Remove existing recommendations of this type
      _recommendations.removeWhere((rec) => rec.type == type);

      // Extract user preferences for personalization
      final interests = (userProfile['interests'] as List?)?.cast<String>() ?? [];
      final mentalHealthAreas = (userProfile['mentalHealthHistory'] as List?)?.cast<String>() ?? [];

      // Fetch new recommendations for the specified type with randomization
      switch (type) {
        case RecommendationType.movie:
          // Use random page (1-5) to get different movies
          final randomPage = (DateTime.now().millisecondsSinceEpoch % 5) + 1;
          await _fetchMovies(mood, interests, mentalHealthAreas, page: randomPage);
          break;
        case RecommendationType.video:
          await _fetchVideos(mood, interests, mentalHealthAreas, randomize: true);
          break;
        case RecommendationType.book:
          await _fetchBooks(mood, interests, mentalHealthAreas, randomize: true);
          break;
        default:
          debugPrint('Regeneration not supported for type: $type');
      }

      // Boost relevance scores for content matching user interests
      _boostRelevanceByInterests(interests, mentalHealthAreas);

      // Sort by relevance score
      _recommendations.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error regenerating recommendations: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Boost relevance scores based on user interests and mental health areas
  void _boostRelevanceByInterests(List<String> interests, List<String> mentalHealthAreas) {
    for (var recommendation in _recommendations) {
      double boost = 0.0;
      
      // Check if recommendation tags match user interests
      for (var interest in interests) {
        if (recommendation.tags?.contains(interest) == true ||
            recommendation.title.toLowerCase().contains(interest.toLowerCase()) ||
            recommendation.description?.toLowerCase().contains(interest.toLowerCase()) == true) {
          boost += 1.5;
        }
      }
      
      // Check if recommendation matches mental health focus areas
      for (var area in mentalHealthAreas) {
        if (recommendation.tags?.contains(area) == true ||
            recommendation.title.toLowerCase().contains(area.toLowerCase()) ||
            recommendation.description?.toLowerCase().contains(area.toLowerCase()) == true) {
          boost += 2.0; // Higher boost for mental health matches
        }
      }
      
      // Apply boost to relevance score
      if (boost > 0) {
        recommendation.relevanceScore += boost;
        debugPrint('Boosted "${recommendation.title}" by $boost points (interests/mental health match)');
      }
    }
  }

  // Fetch movies from TMDB API
  Future<void> _fetchMovies(MoodEntry? mood, List<String> interests, List<String> mentalHealthAreas, {int page = 1}) async {
    try {
      final genre = _getMoodBasedGenre(mood, interests, mentalHealthAreas);
      final sortBy = _getMoodBasedSortOrder(mood);
      
      final url = Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?api_key=${ApiConfig.tmdbApiKey}'
        '&with_genres=$genre'
        '&sort_by=$sortBy'
        '&vote_count.gte=100' // Ensure quality movies
        '&language=en-US'
        '&include_adult=false'
        '&page=$page',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;

        // Filter out movies without poster or overview
        final validMovies = movies.where((movie) => 
          movie['poster_path'] != null && 
          movie['overview'] != null &&
          movie['overview'].toString().isNotEmpty
        ).toList();

        for (var movie in validMovies.take(10)) {
          _recommendations.add(Recommendation(
            id: movie['id'].toString(),
            type: RecommendationType.movie,
            title: movie['title'] ?? 'Unknown Title',
            description: movie['overview'] ?? '',
            imageUrl: movie['poster_path'] != null 
              ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
              : null,
            actionUrl: 'https://www.themoviedb.org/movie/${movie['id']}',
            relevanceScore: (movie['vote_average'] ?? 0).toDouble(),
            metadata: {
              'rating': movie['vote_average'] ?? 0,
              'release_date': movie['release_date'] ?? '',
              'vote_count': movie['vote_count'] ?? 0,
              'mood_match': _getMoodMatchDescription(mood),
            },
            tags: [genre, mood?.mood.toString().split('.').last ?? 'general'],
          ));
        }
        
        debugPrint('Successfully fetched ${validMovies.take(10).length} movies for mood: ${mood?.mood}');
      } else {
        debugPrint('TMDB API error: ${response.statusCode} - ${response.body}');
        _addFallbackMovies(mood);
      }
    } catch (e) {
      debugPrint('Error fetching movies: $e');
      _addFallbackMovies(mood);
    }
  }

  // Fetch books from Google Books API
  Future<void> _fetchBooks(MoodEntry? mood, List<String> interests, List<String> mentalHealthAreas, {bool randomize = false}) async {
    try {
      String query = _getMoodBasedBookQuery(mood, interests, mentalHealthAreas);
      // Add randomization to query for variety
      if (randomize) {
        final randomSuffixes = ['best', 'popular', 'recommended', 'top', 'new'];
        final randomSuffix = randomSuffixes[DateTime.now().millisecondsSinceEpoch % randomSuffixes.length];
        query = '$query $randomSuffix';
      }
      final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=$query'
        '&maxResults=10'
        '&orderBy=relevance'
        '&printType=books'
        '&langRestrict=en'
        '&key=${ApiConfig.googleBooksApiKey}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final books = data['items'] as List? ?? [];

        if (books.isEmpty) {
          debugPrint('No books found for query: $query');
          _addFallbackBooks(mood);
          return;
        }

        for (var book in books) {
          final volumeInfo = book['volumeInfo'];
          final title = volumeInfo['title'] as String?;
          
          // Skip books without essential info
          if (title == null || title.isEmpty) continue;

          // Get the best available image URL
          // Google Books API provides imageLinks with different sizes:
          // smallThumbnail, thumbnail, small, medium, large, extraLarge
          // Note: Some books may not have imageLinks, so imageUrl can be null
          String? imageUrl;
          if (volumeInfo['imageLinks'] != null) {
            final imageLinks = volumeInfo['imageLinks'] as Map;
            // Try to get the best quality image available
            imageUrl = imageLinks['medium'] ?? 
                      imageLinks['large'] ?? 
                      imageLinks['thumbnail'] ?? 
                      imageLinks['small'] ??
                      imageLinks['smallThumbnail'] ??
                      imageLinks['extraLarge'];
            // Use HTTPS for image URLs and replace http with https
            if (imageUrl != null && imageUrl.startsWith('http:')) {
              imageUrl = imageUrl.replaceFirst('http:', 'https:');
            }
            // Remove the &zoom parameter if present to get full size
            if (imageUrl != null && imageUrl.contains('&zoom=')) {
              imageUrl = imageUrl.split('&zoom=')[0];
            }
          } else {
            debugPrint('Book "$title" has no imageLinks in Google Books API');
          }

          final authors = volumeInfo['authors'] as List?;
          final description = volumeInfo['description'] as String?;
          final averageRating = volumeInfo['averageRating'] as num?;
          
          _recommendations.add(Recommendation(
            id: book['id'],
            type: RecommendationType.book,
            title: title,
            subtitle: authors != null && authors.isNotEmpty 
              ? authors.join(', ') 
              : 'Unknown Author',
            description: description != null && description.isNotEmpty
              ? description.length > 300 
                ? '${description.substring(0, 300)}...'
                : description
              : 'A recommended book for your current mood',
            imageUrl: imageUrl,
            actionUrl: volumeInfo['infoLink'] ?? 
                      'https://www.google.com/search?q=${Uri.encodeComponent(title)}+book',
            relevanceScore: averageRating?.toDouble() ?? 7.5,
            metadata: {
              'authors': authors ?? [],
              'publisher': volumeInfo['publisher'] ?? '',
              'publishedDate': volumeInfo['publishedDate'] ?? '',
              'pageCount': volumeInfo['pageCount'] ?? 0,
              'categories': volumeInfo['categories'] ?? [],
              'averageRating': averageRating ?? 0,
              'ratingsCount': volumeInfo['ratingsCount'] ?? 0,
              'mood_match': _getMoodMatchDescription(mood),
            },
            tags: [query, mood?.mood.toString().split('.').last ?? 'wellness'],
          ));
        }
        
        debugPrint('Successfully fetched ${books.length} books for mood: ${mood?.mood}');
      } else {
        debugPrint('Google Books API error: ${response.statusCode} - ${response.body}');
        _addFallbackBooks(mood);
      }
    } catch (e) {
      debugPrint('Error fetching books: $e');
      _addFallbackBooks(mood);
    }
  }

  // Fetch YouTube videos
  Future<void> _fetchVideos(MoodEntry? mood, List<String> interests, List<String> mentalHealthAreas, {bool randomize = false}) async {
    try {
      String query = _getMoodBasedVideoQuery(mood, interests, mentalHealthAreas);
      // Add randomization to query for variety
      if (randomize) {
        final randomSuffixes = ['guided', 'best', 'top', 'popular', 'recommended'];
        final randomSuffix = randomSuffixes[DateTime.now().millisecondsSinceEpoch % randomSuffixes.length];
        query = '$query $randomSuffix';
      }
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&maxResults=8&key=${ApiConfig.youtubeApiKey}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videos = data['items'] as List? ?? [];

        for (var video in videos) {
          final snippet = video['snippet'];
          // YouTube API provides thumbnails in different sizes: default, medium, high, standard, maxres
          final thumbnails = snippet['thumbnails'] as Map?;
          String? imageUrl;
          if (thumbnails != null) {
            imageUrl = thumbnails['high']?['url'] ?? 
                      thumbnails['standard']?['url'] ??
                      thumbnails['maxres']?['url'] ??
                      thumbnails['medium']?['url'] ??
                      thumbnails['default']?['url'];
          }
          
          _recommendations.add(Recommendation(
            id: video['id']['videoId'],
            type: RecommendationType.video,
            title: snippet['title'],
            description: snippet['description'],
            imageUrl: imageUrl,
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
      // URL encode the location parameter
      final encodedLocation = Uri.encodeComponent(location);
      final url = Uri.parse(
        'https://api.yelp.com/v3/businesses/search?term=therapist&location=$encodedLocation&limit=3',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${ApiConfig.yelpApiKey}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final businesses = data['businesses'] as List? ?? [];

        if (businesses.isEmpty) {
          debugPrint('No therapists found for location: $location');
          _addFallbackTherapists();
          return;
        }

        for (var business in businesses) {
          // Yelp API provides image_url, but some businesses might not have images
          final imageUrl = business['image_url'] as String?;
          
          _recommendations.add(Recommendation(
            id: business['id'],
            type: RecommendationType.therapist,
            title: business['name'],
            subtitle: business['location']?['address1'] ?? 'Location not available',
            description: 'Rating: ${business['rating']} ⭐ (${business['review_count']} reviews)',
            //imageUrl: imageUrl?.isNotEmpty == true ? imageUrl : null,
            actionUrl: business['url'],
            relevanceScore: business['rating'].toDouble(),
            metadata: {
              'phone': business['phone'] ?? '',
              'distance': business['distance'] ?? 0,
              'price': business['price'] ?? '',
            },
          ));
        }
        
        debugPrint('Successfully fetched ${businesses.length} therapists for location: $location');
      } else {
        debugPrint('Yelp API error: ${response.statusCode} - ${response.body}');
        _addFallbackTherapists();
      }
    } catch (e) {
      debugPrint('Error fetching therapists: $e');
      _addFallbackTherapists();
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
          imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop',
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
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop',
        relevanceScore: 9.0,
      ));
    }
  }

  // Fetch nutrition tips
  Future<void> _fetchNutritionTips(MoodEntry? mood, List<String> interests) async {
    final tips = _getMoodBasedNutritionTips(mood, interests);
    _recommendations.add(tips);
  }

  // Helper: Get movie genre based on mood and user interests
  String _getMoodBasedGenre(MoodEntry? mood, List<String> interests, List<String> mentalHealthAreas) {
    // If user has specific interests, prioritize those
    if (interests.contains('growth') || mentalHealthAreas.contains('general')) {
      return '18,99'; // Drama & Documentary for personal growth
    }
    if (interests.contains('stress_relief') || mentalHealthAreas.contains('stress')) {
      return '35,10751'; // Comedy & Family for stress relief
    }
    if (interests.contains('sleep') || mentalHealthAreas.contains('sleep_issues')) {
      return '99,36'; // Documentary & History for relaxing content
    }
    
    if (mood == null) return '35'; // Comedy by default

    switch (mood.mood) {
      case MoodType.sad:
      case MoodType.verySad:
        return '35,10751'; // Comedy & Family - uplifting content
      case MoodType.anxious:
      case MoodType.stressed:
        return '18,10749'; // Drama & Romance - calming narratives
      case MoodType.happy:
      case MoodType.veryHappy:
        return '12,28'; // Adventure & Action - exciting content
      case MoodType.calm:
        return '99,36'; // Documentary & History - informative and relaxing
      case MoodType.tired:
        return '16,35'; // Animation & Comedy - light entertainment
      case MoodType.energetic:
        return '28,12'; // Action & Adventure - exciting content
      case MoodType.neutral:
        return '35,18'; // Comedy & Drama - balanced mix
      default:
        return '35'; // Comedy
    }
  }

  // Helper: Get movie sort order based on mood
  String _getMoodBasedSortOrder(MoodEntry? mood) {
    if (mood == null) return 'popularity.desc';

    switch (mood.mood) {
      case MoodType.sad:
      case MoodType.verySad:
        return 'vote_average.desc'; // Highly rated uplifting movies
      case MoodType.anxious:
      case MoodType.stressed:
        return 'vote_average.desc'; // Quality over popularity
      case MoodType.happy:
      case MoodType.veryHappy:
        return 'popularity.desc'; // Trending exciting content
      default:
        return 'popularity.desc';
    }
  }

  // Helper: Get mood match description
  String _getMoodMatchDescription(MoodEntry? mood) {
    if (mood == null) return 'General recommendation';

    switch (mood.mood) {
      case MoodType.sad:
      case MoodType.verySad:
        return 'Uplifting content to brighten your mood';
      case MoodType.anxious:
      case MoodType.stressed:
        return 'Calming content to help you relax';
      case MoodType.happy:
      case MoodType.veryHappy:
        return 'Exciting content to match your energy';
      case MoodType.calm:
        return 'Peaceful content to maintain your tranquility';
      case MoodType.tired:
        return 'Light content that won\'t drain your energy';
      case MoodType.energetic:
        return 'Exciting content to channel your energy';
      default:
        return 'Content matched to your current state';
    }
  }

  // Helper: Get book query based on mood and user preferences
  String _getMoodBasedBookQuery(MoodEntry? mood, List<String> interests, List<String> mentalHealthAreas) {
    // Build query from user interests and mental health areas
    List<String> queryParts = [];
    
    if (interests.contains('meditation')) queryParts.add('mindfulness');
    if (interests.contains('journaling')) queryParts.add('self-reflection');
    if (interests.contains('growth')) queryParts.add('personal+development');
    if (interests.contains('stress_relief')) queryParts.add('stress+management');
    
    if (mentalHealthAreas.contains('anxiety')) queryParts.add('anxiety+relief');
    if (mentalHealthAreas.contains('depression')) queryParts.add('depression+help');
    if (mentalHealthAreas.contains('stress')) queryParts.add('stress+reduction');
    if (mentalHealthAreas.contains('sleep_issues')) queryParts.add('better+sleep');
    
    if (queryParts.isNotEmpty) {
      return queryParts.join('+');
    }
    
    if (mood == null) return 'self-help+wellness+mental+health';

    switch (mood.mood) {
      case MoodType.anxious:
        return 'anxiety+relief+mindfulness+calm';
      case MoodType.stressed:
        return 'stress+management+relaxation+meditation';
      case MoodType.sad:
      case MoodType.verySad:
        return 'inspirational+uplifting+motivation+positive';
      case MoodType.happy:
      case MoodType.veryHappy:
        return 'personal+growth+success+achievement';
      case MoodType.calm:
        return 'mindfulness+meditation+peace+tranquility';
      case MoodType.tired:
        return 'energy+vitality+self-care+rest';
      case MoodType.energetic:
        return 'achievement+motivation+success+action';
      case MoodType.neutral:
        return 'self-improvement+wellness+balance';
      default:
        return 'mental+health+wellness+self-care';
    }
  }

  // Helper: Get video query based on mood and user preferences
  String _getMoodBasedVideoQuery(MoodEntry? mood, List<String> interests, List<String> mentalHealthAreas) {
    // Build query from user interests and mental health areas
    List<String> queryParts = [];
    
    if (interests.contains('meditation')) queryParts.add('meditation');
    if (interests.contains('breathing')) queryParts.add('breathing exercises');
    if (interests.contains('fitness')) queryParts.add('yoga');
    if (interests.contains('stress_relief')) queryParts.add('stress relief');
    
    if (mentalHealthAreas.contains('anxiety')) queryParts.add('anxiety relief');
    if (mentalHealthAreas.contains('depression')) queryParts.add('uplifting motivation');
    if (mentalHealthAreas.contains('stress')) queryParts.add('stress management');
    
    if (queryParts.isNotEmpty) {
      return queryParts.join(' ');
    }
    
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
      case MoodType.energetic:
        return 'high energy workout motivation';
      default:
        return 'guided meditation mindfulness';
    }
  }

  // Helper: Get curated playlists based on mood
  List<Recommendation> _getCuratedPlaylists(MoodEntry? mood) {
    // Curated playlist recommendations with proper image URLs
    final playlists = <Recommendation>[];
    
    if (mood == null || mood.mood == MoodType.calm || mood.mood == MoodType.anxious) {
      playlists.add(Recommendation(
        id: 'playlist_peaceful',
        type: RecommendationType.music,
        title: 'Peaceful Piano',
        description: 'Relax and unwind with beautiful piano pieces',
        imageUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=500&h=500&fit=crop',
        relevanceScore: 8.5,
      ));
    }
    
    if (mood == null || mood.mood == MoodType.sad || mood.mood == MoodType.verySad) {
      playlists.add(Recommendation(
        id: 'playlist_uplifting',
        type: RecommendationType.music,
        title: 'Uplifting Melodies',
        description: 'Feel-good songs to brighten your day',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=500&fit=crop',
        relevanceScore: 8.5,
      ));
    }
    
    if (mood == null || mood.mood == MoodType.energetic || mood.mood == MoodType.happy) {
      playlists.add(Recommendation(
        id: 'playlist_energetic',
        type: RecommendationType.music,
        title: 'Energy Boost',
        description: 'High-energy tracks to match your vibe',
        imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&h=500&fit=crop',
        relevanceScore: 8.5,
      ));
    }
    
    // Default playlist if none added
    if (playlists.isEmpty) {
      playlists.add(Recommendation(
        id: 'playlist_default',
        type: RecommendationType.music,
        title: 'Mindful Sounds',
        description: 'Curated music for mindfulness and relaxation',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=500&fit=crop',
        relevanceScore: 8.0,
      ));
    }
    
    return playlists;
  }

  // Helper: Get nutrition tips based on mood and interests
  Recommendation _getMoodBasedNutritionTips(MoodEntry? mood, List<String> interests) {
    String tip = 'Stay hydrated and eat balanced meals for optimal wellness';
    
    // Provide interest-specific nutrition tips
    if (interests.contains('fitness')) {
      tip = 'Fuel your workouts with protein and complex carbs. Stay hydrated throughout the day!';
    } else if (interests.contains('sleep')) {
      tip = 'Avoid caffeine after 2pm and try foods rich in magnesium for better sleep quality.';
    } else if (interests.contains('stress_relief')) {
      tip = 'Reduce caffeine and try foods rich in omega-3s and B vitamins to manage stress naturally.';
    } else if (mood != null) {
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
      imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500&h=500&fit=crop',
      relevanceScore: 7.0,
    );
  }

  // Fallback movies when API fails or returns no results
  void _addFallbackMovies(MoodEntry? mood) {
    final fallbackMovies = [
      {
        'id': 'fallback_movie_1',
        'title': 'The Pursuit of Happyness',
        'description': 'An inspiring story about overcoming challenges and finding happiness.',
        'genre': 'Inspirational Drama',
      },
      {
        'id': 'fallback_movie_2',
        'title': 'Inside Out',
        'description': 'A beautiful exploration of emotions and mental health.',
        'genre': 'Animation',
      },
      {
        'id': 'fallback_movie_3',
        'title': 'Good Will Hunting',
        'description': 'A touching story about healing and personal growth.',
        'genre': 'Drama',
      },
    ];

    for (var movie in fallbackMovies) {
      _recommendations.add(Recommendation(
        id: movie['id'] as String,
        type: RecommendationType.movie,
        title: movie['title'] as String,
        description: movie['description'] as String,
        relevanceScore: 8.0,
        metadata: {
          'genre': movie['genre'],
          'fallback': true,
        },
      ));
    }
    
    debugPrint('Added ${fallbackMovies.length} fallback movies');
  }

  // Fallback books when API fails or returns no results
  void _addFallbackBooks(MoodEntry? mood) {
    final fallbackBooks = [
      {
        'id': 'fallback_book_1',
        'title': 'The Power of Now',
        'author': 'Eckhart Tolle',
        'description': 'A guide to spiritual enlightenment and living in the present moment.',
        'imageUrl': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop',
      },
      {
        'id': 'fallback_book_2',
        'title': 'Mindfulness in Plain English',
        'author': 'Bhante Henepola Gunaratana',
        'description': 'A practical guide to meditation and mindfulness practice.',
        'imageUrl': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop',
      },
      {
        'id': 'fallback_book_3',
        'title': 'The Gifts of Imperfection',
        'author': 'Brené Brown',
        'description': 'Let go of who you think you\'re supposed to be and embrace who you are.',
        'imageUrl': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop',
      },
      {
        'id': 'fallback_book_4',
        'title': 'Feeling Good',
        'author': 'David D. Burns',
        'description': 'The clinically proven drug-free treatment for depression.',
        'imageUrl': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop',
      },
    ];

    for (var book in fallbackBooks) {
      _recommendations.add(Recommendation(
        id: book['id'] as String,
        type: RecommendationType.book,
        title: book['title'] as String,
        subtitle: book['author'] as String,
        description: book['description'] as String,
        imageUrl: book['imageUrl'] as String,
        relevanceScore: 8.5,
        metadata: {
          'fallback': true,
        },
      ));
    }
    
    debugPrint('Added ${fallbackBooks.length} fallback books');
  }

  // Fallback therapists when API fails or returns no results
  void _addFallbackTherapists() {
    final fallbackTherapists = [
      {
        'id': 'fallback_therapist_1',
        'name': 'BetterHelp - Online Therapy',
        'address': 'Online Therapy Platform',
        'description': 'Rating: 4.5 ⭐ (50,000+ reviews) - Connect with licensed therapists online',
        'url': 'https://www.betterhelp.com',
        'imageUrl': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=500&h=500&fit=crop',
      },
      {
        'id': 'fallback_therapist_2',
        'name': 'Talkspace - Therapy Made Simple',
        'address': 'Online Therapy Platform',
        'description': 'Rating: 4.6 ⭐ (30,000+ reviews) - Get matched with a therapist',
        'url': 'https://www.talkspace.com',
        'imageUrl': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=500&h=500&fit=crop',
      },
      {
        'id': 'fallback_therapist_3',
        'name': 'Psychology Today - Find a Therapist',
        'address': 'Therapist Directory',
        'description': 'Rating: 4.7 ⭐ (100,000+ reviews) - Search for local therapists',
        'url': 'https://www.psychologytoday.com',
        'imageUrl': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=500&h=500&fit=crop',
      },
    ];

    for (var therapist in fallbackTherapists) {
      _recommendations.add(Recommendation(
        id: therapist['id'] as String,
        type: RecommendationType.therapist,
        title: therapist['name'] as String,
        subtitle: therapist['address'] as String,
        description: therapist['description'] as String,
        imageUrl: therapist['imageUrl'] as String,
        actionUrl: therapist['url'] as String,
        relevanceScore: 8.5,
        metadata: {
          'fallback': true,
        },
      ));
    }
    
    debugPrint('Added ${fallbackTherapists.length} fallback therapists');
  }
}

