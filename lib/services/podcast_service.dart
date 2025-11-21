import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import '../models/mood_entry.dart';
import '../config/api_config.dart';
import 'tts_service.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show AudioElement;

class PodcastService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  html.AudioElement? _webAudioPlayer;

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
    if (kIsWeb) {
      // Initialize web audio player
      _webAudioPlayer = html.AudioElement();
      _webAudioPlayer!.onPlay.listen((_) {
        _isPlaying = true;
        notifyListeners();
      });
      _webAudioPlayer!.onPause.listen((_) {
        _isPlaying = false;
        notifyListeners();
      });
      _webAudioPlayer!.onDurationChange.listen((_) {
        _duration = Duration(seconds: _webAudioPlayer!.duration.toInt());
        notifyListeners();
      });
      _webAudioPlayer!.onTimeUpdate.listen((_) {
        _position = Duration(seconds: _webAudioPlayer!.currentTime.toInt());
        notifyListeners();
      });
    } else {
      // Listen to player state changes for mobile
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
  }

  String? _currentScript;
  String? get currentScript => _currentScript;

  // Generate daily podcast based on user's mood and history
  Future<String?> generateDailyPodcast(MoodEntry? mood, List<MoodEntry> history) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // Check if user is authenticated
      if (_auth.currentUser == null) {
        debugPrint('❌ Cannot generate podcast: User not authenticated');
        _currentPodcastUrl = 'DEMO_MODE';
        _isGenerating = false;
        notifyListeners();
        return 'DEMO_MODE';
      }

      debugPrint('✅ User authenticated: ${_auth.currentUser?.email}');
      
      // Generate script based on mood and history
      final script = _generatePodcastScript(mood, history);
      _currentScript = script;
      
      debugPrint('📝 Generated script (${script.length} chars)');
      debugPrint('🎙️ Calling TTS service...');

      // Try to generate voice audio
      final audioUrl = await _generateVoiceFromText(script);

      if (audioUrl != null) {
        debugPrint('✅ Successfully generated podcast: $audioUrl');
        _currentPodcastUrl = audioUrl;
        
        // Save podcast record to Firestore
        await _savePodcastRecord(audioUrl, script);
      } else {
        // Demo mode: Set a flag that we have a script but no audio
        // The UI can show the script as text
        debugPrint('❌ TTS not available, using demo mode with script only');
        _currentPodcastUrl = 'DEMO_MODE'; // Special flag for demo
      }

      _isGenerating = false;
      notifyListeners();
      return audioUrl ?? 'DEMO_MODE';
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
  // Option 1: Using Cloud Function (Recommended for Production)
  Future<String?> _generateVoiceFromText(String text) async {
    try {
      debugPrint('🔧 Cloud Functions URL: ${ApiConfig.cloudFunctionsUrl}');
      
      // Check if Cloud Functions URL is configured
      if (ApiConfig.cloudFunctionsUrl != 'YOUR_CLOUD_FUNCTIONS_URL_HERE') {
        debugPrint('☁️ Using Cloud Function approach');
        // Use Cloud Function approach
        final result = await TtsService.generateSpeechViaCloudFunction(
          text: text,
          voiceName: 'en-US-Neural2-F',
          languageCode: 'en-US',
        );
        debugPrint('☁️ Cloud Function result: ${result != null ? "Success" : "Failed"}');
        return result;
      } else {
        debugPrint('📱 Using direct API approach');
        // Fallback to direct API approach (for development/testing)
        return await _generateVoiceFromTextDirect(text);
      }
    } catch (e) {
      debugPrint('❌ Error calling TTS service: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      return null;
    }
  }

  // Option 2: Direct API call (simpler but less secure - good for development)
  Future<String?> _generateVoiceFromTextDirect(String text) async {
    try {
      if (!TtsService.isConfigured) {
        debugPrint('TTS API key not configured');
        return null;
      }

      final audioBytes = await TtsService.generateSpeechDirect(
        text: text,
        voiceName: 'en-US-Neural2-F',
        languageCode: 'en-US',
        speakingRate: 1.0,
        pitch: 0.0,
      );

      if (audioBytes == null) return null;

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/podcast_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await tempFile.writeAsBytes(audioBytes);

      return tempFile.path;
    } catch (e) {
      debugPrint('Error generating speech directly: $e');
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
      debugPrint('🎵 Attempting to play podcast from: $url');
      
      if (kIsWeb && _webAudioPlayer != null) {
        // Use HTML5 Audio for web
        debugPrint('🌐 Using HTML5 Audio for web');
        _webAudioPlayer!.src = url;
        _webAudioPlayer!.load();
        _webAudioPlayer!.play();
        debugPrint('✅ Web audio player started successfully');
      } else {
        // Use audioplayers for mobile
        debugPrint('📱 Using audioplayers for mobile');
        await _audioPlayer.stop(); // Stop any existing playback
        await _audioPlayer.play(UrlSource(url));
        debugPrint('✅ Audio player started successfully');
      }
    } catch (e) {
      debugPrint('❌ Error playing podcast: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
    }
  }

  // Pause podcast
  Future<void> pause() async {
    if (kIsWeb && _webAudioPlayer != null) {
      _webAudioPlayer!.pause();
    } else {
      await _audioPlayer.pause();
    }
  }

  // Resume podcast
  Future<void> resume() async {
    if (kIsWeb && _webAudioPlayer != null) {
      _webAudioPlayer!.play();
    } else {
      await _audioPlayer.resume();
    }
  }

  // Stop podcast
  Future<void> stop() async {
    if (kIsWeb && _webAudioPlayer != null) {
      _webAudioPlayer!.pause();
      _webAudioPlayer!.currentTime = 0;
    } else {
      await _audioPlayer.stop();
    }
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    if (kIsWeb && _webAudioPlayer != null) {
      _webAudioPlayer!.currentTime = position.inSeconds.toDouble();
    } else {
      await _audioPlayer.seek(position);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

