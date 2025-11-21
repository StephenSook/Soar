# Movie & Book Recommendations Guide

## Overview

The SOAR app now includes enhanced movie and book recommendation features that provide personalized content suggestions based on the user's current mood. These features use well-established APIs to deliver high-quality recommendations.

## Features Implemented

### 🎬 Movie Recommendations (TMDB API)

The movie recommendation feature uses **The Movie Database (TMDB) API** to fetch personalized movie suggestions.

#### Key Features:
- **Mood-Based Genre Selection**: Automatically selects appropriate movie genres based on user's current mood
- **Quality Filtering**: Only shows movies with at least 100 votes to ensure quality
- **Smart Sorting**: Uses different sorting strategies (popularity vs. rating) depending on mood
- **Rich Metadata**: Includes movie posters, descriptions, ratings, and release dates
- **Fallback Support**: Provides curated recommendations if API fails

#### Mood-to-Genre Mapping:

| Mood | Genres | Rationale |
|------|--------|-----------|
| Sad/Very Sad | Comedy & Family | Uplifting content to brighten mood |
| Anxious/Stressed | Drama & Romance | Calming narratives to reduce anxiety |
| Happy/Very Happy | Adventure & Action | Exciting content to match energy |
| Calm | Documentary & History | Informative and relaxing content |
| Tired | Animation & Comedy | Light entertainment that's easy to watch |
| Angry | Documentary & Drama | Reflective content to process emotions |
| Neutral | Comedy & Drama | Balanced mix of genres |

#### API Details:
```
Endpoint: https://api.themoviedb.org/3/discover/movie
Parameters:
  - api_key: Your TMDB API key
  - with_genres: Mood-based genre IDs
  - sort_by: popularity.desc or vote_average.desc
  - vote_count.gte: 100 (quality filter)
  - language: en-US
  - include_adult: false
```

### 📚 Book Recommendations (Google Books API)

The book recommendation feature uses **Google Books API** to fetch relevant self-help and wellness books.

#### Key Features:
- **Mood-Based Search Queries**: Tailored search terms based on user's emotional state
- **Comprehensive Results**: Returns up to 5 books per query
- **Rich Book Data**: Includes cover images, authors, descriptions, ratings, and page counts
- **Secure Image URLs**: Automatically converts HTTP to HTTPS for security
- **Smart Fallbacks**: Provides curated wellness books if API fails

#### Mood-to-Query Mapping:

| Mood | Search Query | Purpose |
|------|--------------|---------|
| Anxious | anxiety+relief+mindfulness+calm | Books about managing anxiety |
| Stressed | stress+management+relaxation+meditation | Stress reduction techniques |
| Sad/Very Sad | inspirational+uplifting+motivation+positive | Uplifting and motivational content |
| Happy/Very Happy | personal+growth+success+achievement | Content to maintain positive momentum |
| Calm | mindfulness+meditation+peace+tranquility | Books to maintain inner peace |
| Tired | energy+vitality+self-care+rest | Books about energy management |
| Angry | emotional+intelligence+anger+management+healing | Emotional processing resources |
| Neutral | self-improvement+wellness+balance | General wellness content |

#### API Details:
```
Endpoint: https://www.googleapis.com/books/v1/volumes
Parameters:
  - q: Mood-based search query
  - maxResults: 5
  - orderBy: relevance
  - printType: books
  - langRestrict: en
  - key: Your Google Books API key
```

## Implementation Details

### Service Architecture

The `RecommendationService` class handles all recommendation fetching:

```dart
class RecommendationService extends ChangeNotifier {
  // Fetches all recommendations in parallel
  Future<void> fetchRecommendations(MoodEntry? mood, Map<String, dynamic> userProfile)
  
  // Individual fetchers
  Future<void> _fetchMovies(MoodEntry? mood)
  Future<void> _fetchBooks(MoodEntry? mood)
  
  // Helper methods for mood mapping
  String _getMoodBasedGenre(MoodEntry? mood)
  String _getMoodBasedBookQuery(MoodEntry? mood)
  String _getMoodMatchDescription(MoodEntry? mood)
  
  // Fallback methods for offline/error scenarios
  void _addFallbackMovies(MoodEntry? mood)
  void _addFallbackBooks(MoodEntry? mood)
}
```

### Error Handling

Both features include robust error handling:

1. **API Failures**: If the API call fails, fallback recommendations are provided
2. **Empty Results**: If no results are found, curated content is shown
3. **Missing Data**: Gracefully handles missing images, descriptions, or other fields
4. **Network Issues**: Catches and logs network errors without crashing

### Data Model

Recommendations are stored using the `Recommendation` model:

```dart
class Recommendation {
  final String id;
  final RecommendationType type; // movie, book, etc.
  final String title;
  final String? subtitle; // Author for books
  final String? description;
  final String? imageUrl;
  final String? actionUrl; // Link to more info
  final Map<String, dynamic> metadata; // Additional data
  final double relevanceScore; // For sorting
  final List<String> tags;
}
```

## API Configuration

### Current API Keys (from `api_config.dart`):

```dart
// TMDB API Key
static const String tmdbApiKey = '9e32438292423421dc5a59fac6ecd29e';

// Google Books API Key  
static const String googleBooksApiKey = 'AIzaSyBmZKv5FHQbwvSzqCVAGcm2UivNOqdtrb4';
```

### API Key Setup:

#### For TMDB:
1. Visit https://www.themoviedb.org/
2. Create a free account
3. Go to Settings → API → Request an API Key
4. Choose "Developer" option
5. Fill in application details
6. Copy your API key to `api_config.dart`

#### For Google Books:
1. Visit https://console.cloud.google.com/
2. Create or select a project
3. Enable "Google Books API" in the API Library
4. Go to Credentials → Create Credentials → API Key
5. Copy your API key to `api_config.dart`

## Usage

### In Your App:

```dart
// Get the recommendation service
final recommendationService = context.read<RecommendationService>();

// Get current mood
final moodService = context.read<MoodService>();
final currentMood = moodService.todaysMood;

// Fetch recommendations
await recommendationService.fetchRecommendations(
  currentMood,
  {
    'interests': ['wellness', 'meditation'],
    'age': 25,
    'location': 'New York, NY',
  },
);

// Access recommendations
final allRecs = recommendationService.recommendations;
final movies = allRecs.where((r) => r.type == RecommendationType.movie);
final books = allRecs.where((r) => r.type == RecommendationType.book);
```

### In the UI:

The `RecommendationsScreen` automatically displays all recommendations in a beautiful card-based layout:

- **Movie Cards**: Show poster, title, description, rating, and "View Details" button
- **Book Cards**: Show cover, title, author(s), description, and "Learn More" button
- **Interactive**: Tapping opens the TMDB page or Google Books info page

## Testing

A test helper is provided in `recommendation_service_test_helper.dart`:

```dart
final testHelper = RecommendationTestHelper();

// Run all tests
final results = await testHelper.testAllFeatures();

// Print detailed results
testHelper.printResults(results);
```

This will test:
- Movie recommendations for different moods (happy, sad, anxious)
- Book recommendations for different moods (stressed, calm, tired)
- API connectivity and response parsing
- Fallback mechanisms

## Fallback Recommendations

If APIs fail or return no results, curated recommendations are provided:

### Fallback Movies:
1. "The Pursuit of Happyness" - Inspirational drama
2. "Inside Out" - Beautiful exploration of emotions
3. "Good Will Hunting" - Story about healing and growth

### Fallback Books:
1. "The Power of Now" by Eckhart Tolle
2. "Mindfulness in Plain English" by Bhante Henepola Gunaratana
3. "The Gifts of Imperfection" by Brené Brown
4. "Feeling Good" by David D. Burns

## Performance Considerations

- **Parallel Fetching**: Movies and books are fetched simultaneously for speed
- **Result Limiting**: Maximum 5 results per category to keep UI responsive
- **Caching**: Consider implementing caching for frequently requested content
- **Image Optimization**: Using TMDB's w500 size for optimal quality/size balance

## Rate Limits

### TMDB API:
- **Free Tier**: 40 requests per 10 seconds
- **Daily**: Practically unlimited for normal use
- **Attribution Required**: Must display "Powered by TMDB" logo

### Google Books API:
- **Free Tier**: 1,000 requests per day
- **Per User**: 10 queries per second per user
- **No Attribution Required**

## Future Enhancements

Potential improvements mentioned in the technical guide:

1. **Personalization Engine**: Use ML to learn user preferences over time
2. **Collaborative Filtering**: Recommend content based on similar users
3. **User Feedback**: Track which recommendations users engage with
4. **Watchlist/Reading List**: Allow users to save recommendations
5. **Streaming Integration**: Deep links to Netflix, Amazon Prime, etc.
6. **Local Bookstores**: Link to nearby bookstores for purchases
7. **Content Safety**: Additional filtering for sensitive content
8. **Multi-language Support**: Recommendations in user's preferred language

## Troubleshooting

### Common Issues:

**Movies not loading:**
- Check TMDB API key is valid
- Verify network connectivity
- Check console for API error messages
- Ensure device can reach api.themoviedb.org

**Books not loading:**
- Check Google Books API key is valid
- Verify the API is enabled in Google Cloud Console
- Check for rate limit errors
- Ensure queries are properly URL-encoded

**Images not displaying:**
- Check image URLs are HTTPS (should auto-convert)
- Verify network permissions in app manifest
- Check if cached_network_image package is installed

## Privacy & Security

- **No Personal Data Sent**: Only mood type is used to determine queries
- **Secure Connections**: All API calls use HTTPS
- **API Keys**: Store API keys securely, never in client code (use backend proxy in production)
- **User Privacy**: No tracking of which content users view
- **GDPR Compliant**: No personal data collected or stored from APIs

## License & Attribution

### TMDB:
- Must display "Powered by TMDB" logo in your app
- Follow TMDB's API Terms of Use
- Free for non-commercial and commercial use

### Google Books:
- Free to use with attribution (though not required)
- Follow Google Books API Terms of Service
- Commercial use allowed

## Support

For issues or questions:
1. Check the SOAR Technical Guide (SOAR_Technical_Guide.txt)
2. Review API documentation:
   - TMDB: https://developers.themoviedb.org/3
   - Google Books: https://developers.google.com/books
3. Check console logs for detailed error messages
4. Test with the provided test helper

---

**Last Updated**: November 21, 2025
**Version**: 1.0.0

