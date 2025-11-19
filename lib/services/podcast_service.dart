import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';
import '../config/api_config.dart';

class PodcastService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AudioPlayer get audioPlayer => _audioPlayer;

  String? _currentPodcastUrl;
  String? get currentPodcastUrl => _currentPodcastUrl;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  Duration _position = Duration.zero;
  Duration get position => _position;

  PodcastService() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });
  }

  // Generate daily podcast based on user's mood and history
  Future<String?> generateDailyPodcast(MoodEntry? mood, List<MoodEntry> history) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // Generate script based on mood and history
      final script = _generatePodcastScript(mood, history);

      // Call backend cloud function to generate TTS
      final audioUrl = await _generateVoiceFromText(script);

      if (audioUrl != null) {
        _currentPodcastUrl = audioUrl;
        
        // Save podcast record to Firestore
        await _savePodcastRecord(audioUrl, script);
      }

      _isGenerating = false;
      notifyListeners();
      return audioUrl;
    } catch (e) {
      debugPrint('Error generating podcast: $e');
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  // Generate podcast script based on user data
  String _generatePodcastScript(MoodEntry? mood, List<MoodEntry> history) {
    final StringBuffer script = StringBuffer();

    // Greeting
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    script.writeln('$greeting! Welcome to your daily SOAR moment.');
    script.writeln('');

    // Address current mood
    if (mood != null) {
      script.writeln(_getMoodMessage(mood));
      script.writeln('');
    }

    // Acknowledge streak
    if (history.isNotEmpty) {
      final streak = _calculateStreak(history);
      if (streak > 1) {
        script.writeln('Great job on your $streak-day check-in streak! ');
        script.writeln('Consistency is key to understanding yourself better.');
        script.writeln('');
      }
    }

    // Daily affirmation
    script.writeln(_getAffirmation(mood));
    script.writeln('');

    // Wellness tip
    script.writeln(_getWellnessTip(mood));
    script.writeln('');

    // Closing
    script.writeln('Remember, you are doing great.');
    script.writeln('Take today one moment at a time.');
    script.writeln('Have a wonderful day!');

    return script.toString();
  }

  String _getMoodMessage(MoodEntry mood) {
    switch (mood.mood) {
      case MoodType.veryHappy:
      case MoodType.happy:
        return 'I can feel your positive energy today! That\'s wonderful. '
            'Keep embracing these good vibes.';
      case MoodType.sad:
      case MoodType.verySad:
        return 'I noticed you\'re feeling down today. That\'s okay. '
            'Remember, it\'s perfectly normal to have difficult days. '
            'Be gentle with yourself.';
      case MoodType.anxious:
        return 'Feeling anxious can be challenging. '
            'Take a deep breath with me. In... and out. '
            'You\'ve got this.';
      case MoodType.stressed:
        return 'Stress can feel overwhelming, but you\'re handling it. '
            'Let\'s take a moment to pause and reset.';
      case MoodType.calm:
        return 'Your calm energy is beautiful. '
            'It\'s a gift to feel centered like this.';
      case MoodType.tired:
        return 'Feeling tired? Listen to your body. '
            'Rest is productive, and you deserve it.';
      default:
        return 'Thank you for checking in today. '
            'Your self-awareness is a strength.';
    }
  }

  String _getAffirmation(MoodEntry? mood) {
    // Could be randomized or mood-based
    final affirmations = [
      'You are stronger than you think.',
      'Every day is a new opportunity.',
      'You deserve peace and happiness.',
      'Your feelings are valid.',
      'You are enough, just as you are.',
      'Progress, not perfection.',
      'You have the power to create change.',
    ];

    return 'Here\'s your affirmation for today: ${affirmations[DateTime.now().day % affirmations.length]}';
  }

  String _getWellnessTip(MoodEntry? mood) {
    if (mood == null) {
      return 'Today, try taking a short walk outside. '
          'Fresh air and movement can do wonders for your mood.';
    }

    switch (mood.mood) {
      case MoodType.anxious:
      case MoodType.stressed:
        return 'When feeling anxious, try the 5-4-3-2-1 grounding technique. '
            'Name 5 things you can see, 4 you can touch, 3 you can hear, '
            '2 you can smell, and 1 you can taste.';
      case MoodType.sad:
        return 'When you\'re feeling sad, reach out to someone you trust. '
            'Connection can be healing.';
      case MoodType.tired:
        return 'Prioritize sleep tonight. Try to establish a calming bedtime routine. '
            'Your body will thank you.';
      default:
        return 'Don\'t forget to drink water and nourish your body today. '
            'Self-care is not selfish.';
    }
  }

  int _calculateStreak(List<MoodEntry> history) {
    if (history.isEmpty) return 0;

    int streak = 1;
    DateTime currentDate = history.first.timestamp;

    for (int i = 1; i < history.length; i++) {
      final daysDiff = currentDate.difference(history[i].timestamp).inDays;
      if (daysDiff == 1) {
        streak++;
        currentDate = history[i].timestamp;
      } else {
        break;
      }
    }

    return streak;
  }

  // Call cloud function to generate TTS audio
  Future<String?> _generateVoiceFromText(String text) async {
    try {
      // TODO: Replace with actual Cloud Function URL
      final url = Uri.parse('${ApiConfig.cloudFunctionsUrl}/generatePodcast');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'voice': 'en-US-Neural2-F', // Google Cloud TTS voice
          'languageCode': 'en-US',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['audioUrl']; // URL to the generated MP3
      }

      return null;
    } catch (e) {
      debugPrint('Error calling TTS service: $e');
      return null;
    }
  }

  // Save podcast record
  Future<void> _savePodcastRecord(String audioUrl, String script) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('podcasts')
        .add({
      'audioUrl': audioUrl,
      'script': script,
      'createdAt': Timestamp.now(),
      'listenedAt': null,
      'completed': false,
    });
  }

  // Play podcast
  Future<void> playPodcast(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error playing podcast: $e');
    }
  }

  // Pause podcast
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Resume podcast
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  // Stop podcast
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

