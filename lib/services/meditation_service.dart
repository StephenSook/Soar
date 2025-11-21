import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Meditation Session
class MeditationSession {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final String category; // guided, silent, breathing, body-scan
  final String? audioUrl; // YouTube URL or local asset
  final String? backgroundSound; // Optional ambient sound

  const MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.category,
    this.audioUrl,
    this.backgroundSound,
  });
}

/// Meditation Service
/// 
/// Manages meditation sessions, timer, and audio playback
class MeditationService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isPaused = false;
  
  MeditationSession? _currentSession;
  
  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  Duration get elapsed => _elapsed;
  Duration get duration => _duration;
  MeditationSession? get currentSession => _currentSession;
  double get progress => _duration.inSeconds > 0
      ? _elapsed.inSeconds / _duration.inSeconds
      : 0.0;

  /// Curated meditation sessions
  static const List<MeditationSession> sessions = [
    // Guided meditations
    MeditationSession(
      id: 'guided_1',
      title: '5-Minute Mindfulness',
      description: 'A quick guided meditation to center yourself and find calm.',
      durationMinutes: 5,
      category: 'guided',
    ),
    MeditationSession(
      id: 'guided_2',
      title: '10-Minute Body Scan',
      description: 'Relax each part of your body with this gentle body scan meditation.',
      durationMinutes: 10,
      category: 'body-scan',
    ),
    MeditationSession(
      id: 'guided_3',
      title: '15-Minute Anxiety Relief',
      description: 'Find peace and release anxiety with this calming guided meditation.',
      durationMinutes: 15,
      category: 'guided',
    ),
    MeditationSession(
      id: 'guided_4',
      title: '20-Minute Deep Relaxation',
      description: 'Dive deep into relaxation and let go of stress and tension.',
      durationMinutes: 20,
      category: 'guided',
    ),

    // Silent meditation
    MeditationSession(
      id: 'silent_1',
      title: '5-Minute Silent Sit',
      description: 'Simple silent meditation with gentle bell to start and end.',
      durationMinutes: 5,
      category: 'silent',
      backgroundSound: 'gentle_bell',
    ),
    MeditationSession(
      id: 'silent_2',
      title: '10-Minute Silent Practice',
      description: 'Build your practice with 10 minutes of silent meditation.',
      durationMinutes: 10,
      category: 'silent',
      backgroundSound: 'gentle_bell',
    ),
    MeditationSession(
      id: 'silent_3',
      title: '20-Minute Silent Meditation',
      description: 'Extended silent sitting practice for deeper awareness.',
      durationMinutes: 20,
      category: 'silent',
      backgroundSound: 'gentle_bell',
    ),

    // Breathing focused
    MeditationSession(
      id: 'breath_1',
      title: 'Breath Awareness',
      description: 'Focus on your natural breath with gentle guidance.',
      durationMinutes: 7,
      category: 'breathing',
    ),
    MeditationSession(
      id: 'breath_2',
      title: 'Box Breathing',
      description: 'Practice box breathing for calm and balance.',
      durationMinutes: 5,
      category: 'breathing',
    ),
  ];

  /// Start a meditation session
  void startSession(MeditationSession session) {
    _currentSession = session;
    _duration = Duration(minutes: session.durationMinutes);
    _elapsed = Duration.zero;
    _isPlaying = true;
    _isPaused = false;

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed += const Duration(seconds: 1);
      
      if (_elapsed >= _duration) {
        completeSession();
      }
      
      notifyListeners();
    });

    // Play background sound if available
    if (session.backgroundSound != null) {
      _playBackgroundSound(session.backgroundSound!);
    }

    notifyListeners();
  }

  /// Pause the session
  void pause() {
    _isPaused = true;
    _timer?.cancel();
    _audioPlayer.pause();
    notifyListeners();
  }

  /// Resume the session
  void resume() {
    _isPaused = false;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed += const Duration(seconds: 1);
      
      if (_elapsed >= _duration) {
        completeSession();
      }
      
      notifyListeners();
    });

    _audioPlayer.resume();
    notifyListeners();
  }

  /// Stop the session
  void stop() {
    _timer?.cancel();
    _audioPlayer.stop();
    _isPlaying = false;
    _isPaused = false;
    _elapsed = Duration.zero;
    _currentSession = null;
    notifyListeners();
  }

  /// Complete the session
  void completeSession() {
    _timer?.cancel();
    _audioPlayer.stop();
    _isPlaying = false;
    _isPaused = false;
    
    // Play completion bell
    _playCompletionBell();
    
    notifyListeners();
  }

  /// Play background sound
  Future<void> _playBackgroundSound(String sound) async {
    try {
      // In production, load from assets or Firebase Storage
      // For now, this is a placeholder
      // await _audioPlayer.play(AssetSource('audio/$sound.mp3'));
      // _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('Error playing background sound: $e');
    }
  }

  /// Play completion bell
  Future<void> _playCompletionBell() async {
    try {
      // In production, play a pleasant completion sound
      // await _audioPlayer.play(AssetSource('audio/completion_bell.mp3'));
    } catch (e) {
      debugPrint('Error playing completion bell: $e');
    }
  }

  /// Get sessions by category
  List<MeditationSession> getSessionsByCategory(String category) {
    return sessions.where((s) => s.category == category).toList();
  }

  /// Get recommended session based on duration preference
  MeditationSession? getRecommendedSession(int preferredMinutes) {
    try {
      return sessions.firstWhere(
        (s) => s.durationMinutes == preferredMinutes,
      );
    } catch (e) {
      return sessions.first;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

