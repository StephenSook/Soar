# How to Test Movie & Book Recommendations

## Quick Start Guide

### Option 1: Run Tests from Console

Add this code anywhere in your app (e.g., in a debug screen or during app initialization):

```dart
import 'package:soar/services/recommendation_service_test_helper.dart';

// In an async function:
final testHelper = RecommendationTestHelper();
final results = await testHelper.testAllFeatures();
testHelper.printResults(results);
```

This will run tests and print detailed results to the console/debug output.

---

### Option 2: Use the Visual Test Screen

#### Step 1: Add Test Screen to Your Navigation

In your app's main navigation or settings screen, add a button to access the test screen:

```dart
import 'package:soar/screens/test/recommendation_test_screen.dart';

// In your widget:
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecommendationTestScreen(),
      ),
    );
  },
  child: const Text('Test Recommendations'),
)
```

#### Step 2: Navigate to Test Screen

1. Open your app
2. Navigate to the test screen using the button you added
3. Tap "Run Tests"
4. View the results on screen
5. Check the console for detailed logs

---

### Option 3: Test in Recommendations Screen

The easiest way to test is to use the existing Recommendations screen:

1. **Complete a mood check-in** (this is required to get recommendations)
2. **Navigate to Recommendations** from your home screen
3. **Pull down to refresh** (or tap the refresh button)
4. **View the results**:
   - You should see movie cards with posters
   - You should see book cards with covers
   - Each card should have a title, description, and action button

If you see recommendations, the features are working! 🎉

---

## What to Look For

### ✅ Success Indicators:

**Movies:**
- [ ] 5 movie cards displayed
- [ ] Movie posters load correctly
- [ ] Titles and descriptions are visible
- [ ] Ratings are shown (e.g., "7.5 ⭐")
- [ ] "View Details" button opens TMDB page
- [ ] Movies match your current mood

**Books:**
- [ ] 5 book cards displayed
- [ ] Book covers load correctly
- [ ] Titles and authors are visible
- [ ] Descriptions are shown
- [ ] "Learn More" button opens Google Books page
- [ ] Books are relevant to your mood

### 🚨 Troubleshooting:

**No movies showing?**
- Check your internet connection
- Verify TMDB API key in `lib/config/api_config.dart`
- Check console for error messages
- Should show fallback movies if API fails

**No books showing?**
- Check your internet connection
- Verify Google Books API key in `lib/config/api_config.dart`
- Check console for error messages
- Should show fallback books if API fails

**Images not loading?**
- Check network permissions in AndroidManifest.xml / Info.plist
- Verify `cached_network_image` package is installed
- Check if HTTPS URLs are being used (should auto-convert)

---

## Testing Different Moods

To test how recommendations change based on mood:

1. **Complete a mood check-in** with a specific mood (e.g., "Sad")
2. **Go to Recommendations** and note what movies/books appear
3. **Complete another mood check-in** with a different mood (e.g., "Happy")
4. **Go to Recommendations again** and see how the content changes

### Expected Behavior by Mood:

| Mood | Expected Movies | Expected Books |
|------|----------------|----------------|
| Happy | Adventure/Action films | Personal growth books |
| Sad | Comedy/Family films | Inspirational books |
| Anxious | Drama/Romance films | Anxiety relief books |
| Stressed | Drama films | Stress management books |
| Calm | Documentaries | Mindfulness books |
| Tired | Animation/Comedy | Energy/vitality books |

---

## Console Output

When running tests, you should see output like this:

```
==================================================
RECOMMENDATION SERVICE TEST RESULTS
==================================================

🎬 MOVIES:
  ✓ MoodType.happy: 5 movies found
    - Avengers: Endgame
    - Spider-Man: No Way Home
    - Guardians of the Galaxy
  ✓ MoodType.sad: 5 movies found
    - The Pursuit of Happyness
    - Inside Out
    - Up
  ✓ MoodType.anxious: 5 movies found
    - The Notebook
    - Pride and Prejudice
    - La La Land

📚 BOOKS:
  ✓ MoodType.stressed: 5 books found
    - The Relaxation Response by Herbert Benson
    - Full Catastrophe Living by Jon Kabat-Zinn
    - The Art of Stress-Free Living by Ajahn Brahm
  ✓ MoodType.calm: 5 books found
    - The Miracle of Mindfulness by Thich Nhat Hanh
    - Wherever You Go, There You Are by Jon Kabat-Zinn
    - Peace Is Every Step by Thich Nhat Hanh
  ✓ MoodType.tired: 5 books found
    - Why We Sleep by Matthew Walker
    - The Sleep Revolution by Arianna Huffington
    - Burnout by Emily Nagoski

==================================================
Test completed at: 2025-11-21T10:30:00.000Z
==================================================
```

---

## API Verification

### Verify TMDB API:

1. Open your browser
2. Navigate to: `https://api.themoviedb.org/3/discover/movie?api_key=9e32438292423421dc5a59fac6ecd29e&with_genres=35`
3. You should see JSON data with movies
4. If you see an error, your API key may be invalid

### Verify Google Books API:

1. Open your browser
2. Navigate to: `https://www.googleapis.com/books/v1/volumes?q=mindfulness&key=AIzaSyBmZKv5FHQbwvSzqCVAGcm2UivNOqdtrb4`
3. You should see JSON data with books
4. If you see an error, your API key may be invalid

---

## Performance Testing

### Load Time:
- Recommendations should load within 2-3 seconds
- If loading takes longer, check your internet connection
- Parallel API calls should speed up the process

### Memory Usage:
- Images should be cached to reduce memory usage
- Scrolling through recommendations should be smooth
- No memory leaks should occur

### Network Usage:
- First load: ~40KB total (movies + books)
- Subsequent loads: ~10KB (cached images)
- Offline: Fallback recommendations should appear

---

## Debugging Tips

### Enable Verbose Logging:

In `recommendation_service.dart`, all errors are logged with `debugPrint()`. Look for:
- `"Error fetching movies:"`
- `"Error fetching books:"`
- `"Successfully fetched X movies for mood:"`
- `"Successfully fetched X books for mood:"`

### Check API Response:

Add breakpoints or print statements in:
- `_fetchMovies()` method (line ~47)
- `_fetchBooks()` method (line ~80)

### Test Fallbacks:

To test fallback recommendations:
1. Disconnect from the internet
2. Run the recommendations
3. You should see fallback content (3 curated movies, 4 curated books)

---

## Integration with App

### Current Integration:

The movie and book recommendations are already integrated into:

1. **RecommendationService** (`lib/services/recommendation_service.dart`)
   - Called automatically when fetching recommendations
   - Runs in parallel with other recommendation types

2. **RecommendationsScreen** (`lib/screens/recommendations/recommendations_screen.dart`)
   - Displays all recommendations in a card layout
   - Includes pull-to-refresh functionality
   - Shows empty state if no mood check-in

3. **Home Screen** (likely)
   - Should have a link/button to Recommendations

### To Verify Integration:

```dart
// Check that Provider is set up correctly
final recommendationService = context.watch<RecommendationService>();

// Verify movies are in the list
final movies = recommendationService.recommendations
    .where((r) => r.type == RecommendationType.movie);
    
print('Found ${movies.length} movie recommendations');

// Verify books are in the list
final books = recommendationService.recommendations
    .where((r) => r.type == RecommendationType.book);
    
print('Found ${books.length} book recommendations');
```

---

## Known Issues & Limitations

### Current Limitations:

1. **Adult Content**: Filtered out by default (include_adult=false)
2. **Language**: English only (en-US)
3. **Quality Filter**: Only movies with 100+ votes shown
4. **API Rate Limits**: 
   - TMDB: 40 requests per 10 seconds
   - Google Books: 1,000 requests per day
5. **Internet Required**: No caching for offline use (yet)

### Future Enhancements:

- [ ] Cache recommendations for offline access
- [ ] User preference filtering
- [ ] Multi-language support
- [ ] Streaming platform integration
- [ ] Personalized recommendations based on history
- [ ] Social sharing features

---

## Success Criteria

✅ **Implementation is successful if:**

1. Movies and books appear in the Recommendations screen
2. Content changes based on user's mood
3. Images load correctly
4. External links work (open TMDB/Google Books pages)
5. Fallback content appears if API fails
6. No crashes or errors occur
7. Console shows successful API calls
8. Test screen shows green checkmarks for all tests

---

## Support

If you encounter issues:

1. **Check the Guides**:
   - `MOVIE_BOOK_RECOMMENDATIONS_GUIDE.md` - Comprehensive documentation
   - `IMPLEMENTATION_SUMMARY_MOVIES_BOOKS.md` - Implementation details
   - `SOAR_Technical_Guide.txt` - Original technical specifications

2. **Check Console Logs**: Most errors will be logged with details

3. **Verify API Keys**: Make sure both API keys are valid and enabled

4. **Check Network**: Ensure device has internet access

5. **Test Fallbacks**: Even if APIs fail, fallback content should appear

---

**Last Updated**: November 21, 2025
**Status**: Ready for Testing ✅

