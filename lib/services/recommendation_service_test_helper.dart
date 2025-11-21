/// Test Helper for Recommendation Service
/// 
/// This file helps test the movie and book recommendation features
/// Run this in your app to verify API connections work correctly

import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import 'recommendation_service.dart';

class RecommendationTestHelper {
  final RecommendationService _service = RecommendationService();

  /// Test all recommendation features
  Future<Map<String, dynamic>> testAllFeatures() async {
    final results = <String, dynamic>{
      'movies': await testMovieRecommendations(),
      'books': await testBookRecommendations(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    return results;
  }

  /// Test movie recommendations with different moods
  Future<Map<String, dynamic>> testMovieRecommendations() async {
    debugPrint('🎬 Testing Movie Recommendations...');
    
    final moods = [
      MoodEntry(
        id: 'test1',
        userId: 'test',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
      ),
      MoodEntry(
        id: 'test2',
        userId: 'test',
        mood: MoodType.sad,
        timestamp: DateTime.now(),
      ),
      MoodEntry(
        id: 'test3',
        userId: 'test',
        mood: MoodType.anxious,
        timestamp: DateTime.now(),
      ),
    ];

    final results = <String, dynamic>{};
    
    for (var mood in moods) {
      try {
        await _service.fetchRecommendations(mood, {'location': 'Test Location'});
        
        final movieRecs = _service.recommendations
            .where((r) => r.type == RecommendationType.movie)
            .toList();
        
        results[mood.mood.toString()] = {
          'success': movieRecs.isNotEmpty,
          'count': movieRecs.length,
          'sample_titles': movieRecs.take(3).map((r) => r.title).toList(),
        };
        
        debugPrint('✓ Found ${movieRecs.length} movies for ${mood.mood}');
      } catch (e) {
        results[mood.mood.toString()] = {
          'success': false,
          'error': e.toString(),
        };
        debugPrint('✗ Error testing ${mood.mood}: $e');
      }
    }

    return results;
  }

  /// Test book recommendations with different moods
  Future<Map<String, dynamic>> testBookRecommendations() async {
    debugPrint('📚 Testing Book Recommendations...');
    
    final moods = [
      MoodEntry(
        id: 'test1',
        userId: 'test',
        mood: MoodType.stressed,
        timestamp: DateTime.now(),
      ),
      MoodEntry(
        id: 'test2',
        userId: 'test',
        mood: MoodType.calm,
        timestamp: DateTime.now(),
      ),
      MoodEntry(
        id: 'test3',
        userId: 'test',
        mood: MoodType.tired,
        timestamp: DateTime.now(),
      ),
    ];

    final results = <String, dynamic>{};
    
    for (var mood in moods) {
      try {
        await _service.fetchRecommendations(mood, {'location': 'Test Location'});
        
        final bookRecs = _service.recommendations
            .where((r) => r.type == RecommendationType.book)
            .toList();
        
        results[mood.mood.toString()] = {
          'success': bookRecs.isNotEmpty,
          'count': bookRecs.length,
          'sample_titles': bookRecs.take(3).map((r) => r.title).toList(),
          'sample_authors': bookRecs.take(3).map((r) => r.subtitle ?? 'Unknown').toList(),
        };
        
        debugPrint('✓ Found ${bookRecs.length} books for ${mood.mood}');
      } catch (e) {
        results[mood.mood.toString()] = {
          'success': false,
          'error': e.toString(),
        };
        debugPrint('✗ Error testing ${mood.mood}: $e');
      }
    }

    return results;
  }

  /// Print test results in a readable format
  void printResults(Map<String, dynamic> results) {
    debugPrint('\n' + '=' * 50);
    debugPrint('RECOMMENDATION SERVICE TEST RESULTS');
    debugPrint('=' * 50);
    
    // Movies
    debugPrint('\n🎬 MOVIES:');
    final movies = results['movies'] as Map<String, dynamic>;
    movies.forEach((mood, data) {
      final moodData = data as Map<String, dynamic>;
      if (moodData['success'] == true) {
        debugPrint('  ✓ $mood: ${moodData['count']} movies found');
        final titles = moodData['sample_titles'] as List;
        for (var title in titles) {
          debugPrint('    - $title');
        }
      } else {
        debugPrint('  ✗ $mood: ${moodData['error']}');
      }
    });

    // Books
    debugPrint('\n📚 BOOKS:');
    final books = results['books'] as Map<String, dynamic>;
    books.forEach((mood, data) {
      final moodData = data as Map<String, dynamic>;
      if (moodData['success'] == true) {
        debugPrint('  ✓ $mood: ${moodData['count']} books found');
        final titles = moodData['sample_titles'] as List;
        final authors = moodData['sample_authors'] as List;
        for (var i = 0; i < titles.length; i++) {
          debugPrint('    - ${titles[i]} by ${authors[i]}');
        }
      } else {
        debugPrint('  ✗ $mood: ${moodData['error']}');
      }
    });

    debugPrint('\n' + '=' * 50);
    debugPrint('Test completed at: ${results['timestamp']}');
    debugPrint('=' * 50 + '\n');
  }
}

