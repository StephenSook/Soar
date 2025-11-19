import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';
import '../models/user_model.dart';

class MoodService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<MoodEntry> _moodHistory = [];
  List<MoodEntry> get moodHistory => _moodHistory;

  MoodEntry? _todaysMood;
  MoodEntry? get todaysMood => _todaysMood;

  bool _hasCheckedInToday = false;
  bool get hasCheckedInToday => _hasCheckedInToday;

  // Submit mood check-in
  Future<void> submitMoodCheckIn({
    required MoodType mood,
    required int moodRating,
    String? journalNote,
    Map<String, dynamic>? context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final entry = MoodEntry(
        id: '',
        userId: user.uid,
        timestamp: DateTime.now(),
        mood: mood,
        moodRating: moodRating,
        journalNote: journalNote,
        context: context,
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moodEntries')
          .add(entry.toFirestore());

      _todaysMood = MoodEntry(
        id: docRef.id,
        userId: entry.userId,
        timestamp: entry.timestamp,
        mood: entry.mood,
        moodRating: entry.moodRating,
        journalNote: entry.journalNote,
        detectedSentiment: entry.detectedSentiment,
        tags: entry.tags,
        context: entry.context,
      );

      // Update user's last check-in time
      await _firestore.collection('users').doc(user.uid).update({
        'lastMoodCheckIn': Timestamp.fromDate(DateTime.now()),
      });

      _hasCheckedInToday = true;
      await loadMoodHistory();
      notifyListeners();

      // Trigger any post-check-in actions
      await _onCheckInComplete();
    } catch (e) {
      debugPrint('Error submitting mood check-in: $e');
      rethrow;
    }
  }

  // Check if user has checked in today
  Future<void> checkTodaysCheckIn() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moodEntries')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _todaysMood = MoodEntry.fromFirestore(snapshot.docs.first);
        _hasCheckedInToday = true;
      } else {
        _todaysMood = null;
        _hasCheckedInToday = false;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error checking today\'s check-in: $e');
    }
  }

  // Load mood history
  Future<void> loadMoodHistory({int limit = 30}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moodEntries')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      _moodHistory = snapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading mood history: $e');
    }
  }

  // Get mood statistics
  Map<String, dynamic> getMoodStatistics() {
    if (_moodHistory.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalEntries': 0,
        'moodDistribution': <String, int>{},
        'streak': 0,
      };
    }

    final ratings = _moodHistory.map((e) => e.moodRating).toList();
    final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

    final moodDistribution = <String, int>{};
    for (var entry in _moodHistory) {
      moodDistribution[entry.mood.name] = 
          (moodDistribution[entry.mood.name] ?? 0) + 1;
    }

    return {
      'averageRating': averageRating,
      'totalEntries': _moodHistory.length,
      'moodDistribution': moodDistribution,
      'streak': _calculateStreak(),
    };
  }

  // Calculate check-in streak
  int _calculateStreak() {
    if (_moodHistory.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (var i = 0; i < _moodHistory.length; i++) {
      final entryDate = _moodHistory[i].timestamp;
      final daysDiff = currentDate.difference(entryDate).inDays;
      
      if (daysDiff == streak) {
        streak++;
        currentDate = DateTime(entryDate.year, entryDate.month, entryDate.day);
      } else {
        break;
      }
    }

    return streak;
  }

  // Analyze mood patterns (for ML/recommendations)
  Future<Map<String, dynamic>> analyzeMoodPatterns() async {
    if (_moodHistory.length < 7) {
      return {'insufficient_data': true};
    }

    // Calculate weekly trends
    final last7Days = _moodHistory.take(7).toList();
    final weeklyAverage = last7Days
        .map((e) => e.moodRating)
        .reduce((a, b) => a + b) / 7;

    // Detect common moods
    final moodCounts = <MoodType, int>{};
    for (var entry in _moodHistory) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    final dominantMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'weeklyAverage': weeklyAverage,
      'dominantMood': dominantMood.name,
      'moodVariability': _calculateVariability(),
      'trends': _identifyTrends(),
    };
  }

  double _calculateVariability() {
    if (_moodHistory.length < 2) return 0.0;

    final ratings = _moodHistory.map((e) => e.moodRating.toDouble()).toList();
    final mean = ratings.reduce((a, b) => a + b) / ratings.length;
    final variance = ratings
        .map((r) => (r - mean) * (r - mean))
        .reduce((a, b) => a + b) / ratings.length;

    return variance;
  }

  String _identifyTrends() {
    if (_moodHistory.length < 7) return 'insufficient_data';

    final recent = _moodHistory.take(3).toList();
    final older = _moodHistory.skip(3).take(4).toList();

    final recentAvg = recent
        .map((e) => e.moodRating)
        .reduce((a, b) => a + b) / recent.length;
    final olderAvg = older
        .map((e) => e.moodRating)
        .reduce((a, b) => a + b) / older.length;

    if (recentAvg > olderAvg + 0.5) return 'improving';
    if (recentAvg < olderAvg - 0.5) return 'declining';
    return 'stable';
  }

  // Actions after check-in completion
  Future<void> _onCheckInComplete() async {
    // Unlock blocked apps (will be handled by platform-specific code)
    debugPrint('Check-in complete - unlocking apps');
    
    // Trigger recommendation refresh
    // This will be called by the recommendation service
    
    // Maybe generate daily podcast
    // This will be handled by podcast service
  }

  // Optional: Sentiment analysis on journal text
  Future<String?> analyzeSentiment(String text) async {
    // TODO: Implement sentiment analysis
    // Options:
    // 1. Use on-device TFLite model
    // 2. Call cloud function with NLP API
    // 3. Use simple keyword matching for MVP
    
    // For now, return null (can be implemented later)
    return null;
  }
}

