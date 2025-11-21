import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry.dart';
import '../models/mood_entry.dart';

/// Journal Service
/// 
/// Manages journal entries and provides mood-based prompts
class JournalService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<JournalEntry> _entries = [];
  List<JournalEntry> get entries => _entries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Comprehensive collection of journaling prompts
  static const List<JournalingPrompt> allPrompts = [
    // Gratitude prompts
    JournalingPrompt(
      id: 'grat_1',
      prompt: 'What are three things you\'re grateful for today?',
      category: 'gratitude',
      relatedMoods: ['happy', 'veryHappy', 'calm'],
    ),
    JournalingPrompt(
      id: 'grat_2',
      prompt: 'Who in your life are you most thankful for and why?',
      category: 'gratitude',
      relatedMoods: ['happy', 'calm'],
    ),
    JournalingPrompt(
      id: 'grat_3',
      prompt: 'What small moment today made you smile?',
      category: 'gratitude',
      relatedMoods: ['happy', 'calm'],
    ),

    // Anxiety/Stress prompts
    JournalingPrompt(
      id: 'anx_1',
      prompt: 'What is making you feel anxious right now? Write it all out.',
      category: 'anxiety',
      relatedMoods: ['anxious', 'stressed'],
    ),
    JournalingPrompt(
      id: 'anx_2',
      prompt: 'What would you tell a friend who was feeling this way?',
      category: 'anxiety',
      relatedMoods: ['anxious', 'stressed', 'sad'],
    ),
    JournalingPrompt(
      id: 'anx_3',
      prompt: 'List 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.',
      category: 'anxiety',
      relatedMoods: ['anxious', 'stressed'],
    ),
    JournalingPrompt(
      id: 'anx_4',
      prompt: 'What is within your control right now? What isn\'t?',
      category: 'anxiety',
      relatedMoods: ['anxious', 'stressed'],
    ),

    // Sadness/Depression prompts
    JournalingPrompt(
      id: 'sad_1',
      prompt: 'Write about a time when you overcame a difficult challenge.',
      category: 'sadness',
      relatedMoods: ['sad', 'verySad'],
    ),
    JournalingPrompt(
      id: 'sad_2',
      prompt: 'What would make today 1% better?',
      category: 'sadness',
      relatedMoods: ['sad', 'verySad', 'tired'],
    ),
    JournalingPrompt(
      id: 'sad_3',
      prompt: 'Describe yourself as if you were your best friend talking about you.',
      category: 'sadness',
      relatedMoods: ['sad', 'verySad'],
    ),
    JournalingPrompt(
      id: 'sad_4',
      prompt: 'What do you need most right now? Compassion? Rest? Connection?',
      category: 'sadness',
      relatedMoods: ['sad', 'verySad', 'tired'],
    ),

    // Self-reflection prompts
    JournalingPrompt(
      id: 'self_1',
      prompt: 'What does your ideal day look like from start to finish?',
      category: 'self-reflection',
    ),
    JournalingPrompt(
      id: 'self_2',
      prompt: 'What is one habit you want to build? What\'s your first small step?',
      category: 'self-reflection',
    ),
    JournalingPrompt(
      id: 'self_3',
      prompt: 'How have you grown in the past year?',
      category: 'self-reflection',
    ),
    JournalingPrompt(
      id: 'self_4',
      prompt: 'What boundaries do you need to set for your well-being?',
      category: 'self-reflection',
    ),
    JournalingPrompt(
      id: 'self_5',
      prompt: 'If you could give your younger self advice, what would it be?',
      category: 'self-reflection',
    ),

    // Energy/Motivation prompts
    JournalingPrompt(
      id: 'energy_1',
      prompt: 'What gives you energy and makes you feel alive?',
      category: 'energy',
      relatedMoods: ['tired', 'calm'],
    ),
    JournalingPrompt(
      id: 'energy_2',
      prompt: 'What small win can you celebrate today?',
      category: 'energy',
      relatedMoods: ['tired', 'happy'],
    ),
    JournalingPrompt(
      id: 'energy_3',
      prompt: 'What would you do if you knew you couldn\'t fail?',
      category: 'energy',
    ),

    // Relationships prompts
    JournalingPrompt(
      id: 'rel_1',
      prompt: 'Write about someone who made a positive impact on your life.',
      category: 'relationships',
    ),
    JournalingPrompt(
      id: 'rel_2',
      prompt: 'What qualities do you value most in your relationships?',
      category: 'relationships',
    ),
    JournalingPrompt(
      id: 'rel_3',
      prompt: 'How can you show someone you care about them today?',
      category: 'relationships',
    ),

    // General/Daily prompts
    JournalingPrompt(
      id: 'gen_1',
      prompt: 'How are you really feeling right now? No filter.',
      category: 'general',
    ),
    JournalingPrompt(
      id: 'gen_2',
      prompt: 'What surprised you today?',
      category: 'general',
    ),
    JournalingPrompt(
      id: 'gen_3',
      prompt: 'Free write: Let your thoughts flow for 5 minutes without stopping.',
      category: 'general',
    ),
    JournalingPrompt(
      id: 'gen_4',
      prompt: 'What lessons did today teach you?',
      category: 'general',
    ),
    JournalingPrompt(
      id: 'gen_5',
      prompt: 'Describe your current emotion as if it were weather. What kind of weather is it?',
      category: 'general',
    ),
  ];

  /// Get mood-based prompts
  List<JournalingPrompt> getPromptsForMood(MoodType? mood) {
    if (mood == null) {
      return allPrompts.where((p) => p.category == 'general').toList();
    }

    final moodString = mood.toString().split('.').last;
    
    // Get prompts that match this mood
    final matchingPrompts = allPrompts.where((prompt) {
      return prompt.relatedMoods.contains(moodString);
    }).toList();

    // If we have matching prompts, return them with some general ones
    if (matchingPrompts.isNotEmpty) {
      final generalPrompts = allPrompts
          .where((p) => p.category == 'general')
          .take(2)
          .toList();
      return [...matchingPrompts, ...generalPrompts];
    }

    // Fallback: return prompts by category based on mood
    String category;
    switch (mood) {
      case MoodType.anxious:
      case MoodType.stressed:
        category = 'anxiety';
        break;
      case MoodType.sad:
      case MoodType.verySad:
        category = 'sadness';
        break;
      case MoodType.happy:
      case MoodType.veryHappy:
        category = 'gratitude';
        break;
      case MoodType.tired:
        category = 'energy';
        break;
      default:
        category = 'general';
    }

    return allPrompts.where((p) => p.category == category).toList();
  }

  /// Get a random prompt
  JournalingPrompt getRandomPrompt({MoodType? mood}) {
    final prompts = getPromptsForMood(mood);
    if (prompts.isEmpty) {
      return allPrompts[DateTime.now().millisecondsSinceEpoch % allPrompts.length];
    }
    return prompts[DateTime.now().millisecondsSinceEpoch % prompts.length];
  }

  /// Load user's journal entries
  Future<void> loadEntries() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journal')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _entries = snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new journal entry
  Future<bool> createEntry({
    required String title,
    required String content,
    String? moodType,
    List<String> tags = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final entry = JournalEntry(
        id: '',
        userId: user.uid,
        title: title,
        content: content,
        timestamp: DateTime.now(),
        moodType: moodType,
        tags: tags,
      );

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journal')
          .add(entry.toFirestore());

      // Add to local list
      _entries.insert(
        0,
        entry.copyWith(id: docRef.id),
      );
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error creating journal entry: $e');
      return false;
    }
  }

  /// Update an existing entry
  Future<bool> updateEntry(JournalEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journal')
          .doc(entry.id)
          .update(entry.toFirestore());

      // Update local list
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = entry;
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
      return false;
    }
  }

  /// Delete an entry
  Future<bool> deleteEntry(String entryId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journal')
          .doc(entryId)
          .delete();

      _entries.removeWhere((e) => e.id == entryId);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(JournalEntry entry) async {
    final updatedEntry = entry.copyWith(isFavorite: !entry.isFavorite);
    return await updateEntry(updatedEntry);
  }

  /// Search entries
  List<JournalEntry> searchEntries(String query) {
    if (query.isEmpty) return _entries;

    final lowerQuery = query.toLowerCase();
    return _entries.where((entry) {
      return entry.title.toLowerCase().contains(lowerQuery) ||
          entry.content.toLowerCase().contains(lowerQuery) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get entries by mood
  List<JournalEntry> getEntriesByMood(String moodType) {
    return _entries.where((entry) => entry.moodType == moodType).toList();
  }

  /// Get favorite entries
  List<JournalEntry> get favoriteEntries {
    return _entries.where((entry) => entry.isFavorite).toList();
  }
}

