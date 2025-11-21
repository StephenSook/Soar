import 'package:flutter/foundation.dart';
import 'dart:async';

/// Breathing Technique
class BreathingTechnique {
  final String id;
  final String name;
  final String description;
  final List<BreathingPhase> phases;
  final int cycles;
  final String benefit;

  const BreathingTechnique({
    required this.id,
    required this.name,
    required this.description,
    required this.phases,
    required this.cycles,
    required this.benefit,
  });

  int get totalDuration {
    final cycleTime = phases.fold<int>(0, (sum, phase) => sum + phase.duration);
    return cycleTime * cycles;
  }
}

/// Breathing Phase (inhale, hold, exhale, hold)
class BreathingPhase {
  final String name;
  final int duration; // in seconds
  final String instruction;

  const BreathingPhase({
    required this.name,
    required this.duration,
    required this.instruction,
  });
}

/// Breathing Service
/// 
/// Manages breathing exercises with animated visual guides
class BreathingService extends ChangeNotifier {
  Timer? _timer;
  int _currentCycle = 0;
  int _currentPhaseIndex = 0;
  int _phaseTimeRemaining = 0;
  bool _isActive = false;
  
  BreathingTechnique? _currentTechnique;
  
  // Getters
  bool get isActive => _isActive;
  int get currentCycle => _currentCycle;
  int get currentPhaseIndex => _currentPhaseIndex;
  int get phaseTimeRemaining => _phaseTimeRemaining;
  BreathingTechnique? get currentTechnique => _currentTechnique;
  
  BreathingPhase? get currentPhase {
    if (_currentTechnique == null) return null;
    return _currentTechnique!.phases[_currentPhaseIndex];
  }

  double get progress {
    if (_currentTechnique == null) return 0.0;
    final currentPhaseDuration = currentPhase?.duration ?? 1;
    return 1.0 - (_phaseTimeRemaining / currentPhaseDuration);
  }

  int get cyclesRemaining {
    if (_currentTechnique == null) return 0;
    return _currentTechnique!.cycles - _currentCycle;
  }

  /// Available breathing techniques
  static const List<BreathingTechnique> techniques = [
    // 4-7-8 Breathing (Relaxing breath)
    BreathingTechnique(
      id: '4_7_8',
      name: '4-7-8 Breathing',
      description: 'A natural tranquilizer for the nervous system. Perfect before sleep or to calm anxiety.',
      cycles: 4,
      benefit: 'Reduces anxiety and helps you fall asleep',
      phases: [
        BreathingPhase(
          name: 'Inhale',
          duration: 4,
          instruction: 'Breathe in through your nose',
        ),
        BreathingPhase(
          name: 'Hold',
          duration: 7,
          instruction: 'Hold your breath',
        ),
        BreathingPhase(
          name: 'Exhale',
          duration: 8,
          instruction: 'Exhale completely through your mouth',
        ),
      ],
    ),

    // Box Breathing (Navy SEAL technique)
    BreathingTechnique(
      id: 'box',
      name: 'Box Breathing',
      description: 'Used by Navy SEALs to stay calm under pressure. Creates balance and focus.',
      cycles: 5,
      benefit: 'Improves focus and manages stress',
      phases: [
        BreathingPhase(
          name: 'Inhale',
          duration: 4,
          instruction: 'Breathe in slowly',
        ),
        BreathingPhase(
          name: 'Hold',
          duration: 4,
          instruction: 'Hold your breath',
        ),
        BreathingPhase(
          name: 'Exhale',
          duration: 4,
          instruction: 'Breathe out slowly',
        ),
        BreathingPhase(
          name: 'Hold',
          duration: 4,
          instruction: 'Hold your breath',
        ),
      ],
    ),

    // Deep Calm Breathing
    BreathingTechnique(
      id: 'deep_calm',
      name: 'Deep Calm',
      description: 'Simple, deep breathing to activate your relaxation response.',
      cycles: 6,
      benefit: 'Quickly reduces stress and tension',
      phases: [
        BreathingPhase(
          name: 'Inhale',
          duration: 5,
          instruction: 'Breathe in deeply through your nose',
        ),
        BreathingPhase(
          name: 'Exhale',
          duration: 5,
          instruction: 'Breathe out slowly through your mouth',
        ),
      ],
    ),

    // Energizing Breath
    BreathingTechnique(
      id: 'energize',
      name: 'Energizing Breath',
      description: 'Quick breathing pattern to boost energy and alertness.',
      cycles: 5,
      benefit: 'Increases energy and mental clarity',
      phases: [
        BreathingPhase(
          name: 'Inhale',
          duration: 2,
          instruction: 'Quick inhale through nose',
        ),
        BreathingPhase(
          name: 'Exhale',
          duration: 2,
          instruction: 'Quick exhale through mouth',
        ),
      ],
    ),

    // Extended Exhale (Anxiety Relief)
    BreathingTechnique(
      id: 'extended_exhale',
      name: 'Extended Exhale',
      description: 'Longer exhales activate the calming parasympathetic nervous system.',
      cycles: 6,
      benefit: 'Powerful for reducing anxiety',
      phases: [
        BreathingPhase(
          name: 'Inhale',
          duration: 4,
          instruction: 'Breathe in gently',
        ),
        BreathingPhase(
          name: 'Exhale',
          duration: 6,
          instruction: 'Breathe out slowly and completely',
        ),
      ],
    ),
  ];

  /// Start a breathing exercise
  void start(BreathingTechnique technique) {
    stop(); // Stop any existing session
    
    _currentTechnique = technique;
    _currentCycle = 0;
    _currentPhaseIndex = 0;
    _phaseTimeRemaining = technique.phases[0].duration;
    _isActive = true;

    _startPhaseTimer();
    notifyListeners();
  }

  /// Start the phase timer
  void _startPhaseTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _phaseTimeRemaining--;

      if (_phaseTimeRemaining <= 0) {
        _nextPhase();
      }

      notifyListeners();
    });
  }

  /// Move to next phase
  void _nextPhase() {
    if (_currentTechnique == null) return;

    _currentPhaseIndex++;

    // Check if we completed all phases in this cycle
    if (_currentPhaseIndex >= _currentTechnique!.phases.length) {
      _currentPhaseIndex = 0;
      _currentCycle++;

      // Check if we completed all cycles
      if (_currentCycle >= _currentTechnique!.cycles) {
        complete();
        return;
      }
    }

    // Start next phase
    _phaseTimeRemaining = _currentTechnique!.phases[_currentPhaseIndex].duration;
  }

  /// Pause the exercise
  void pause() {
    _timer?.cancel();
    _isActive = false;
    notifyListeners();
  }

  /// Resume the exercise
  void resume() {
    if (_currentTechnique != null) {
      _isActive = true;
      _startPhaseTimer();
      notifyListeners();
    }
  }

  /// Stop the exercise
  void stop() {
    _timer?.cancel();
    _currentTechnique = null;
    _currentCycle = 0;
    _currentPhaseIndex = 0;
    _phaseTimeRemaining = 0;
    _isActive = false;
    notifyListeners();
  }

  /// Complete the exercise
  void complete() {
    _timer?.cancel();
    _isActive = false;
    // Keep technique loaded to show completion screen
    notifyListeners();
  }

  /// Reset and restart current technique
  void restart() {
    if (_currentTechnique != null) {
      final technique = _currentTechnique!;
      start(technique);
    }
  }

  /// Get technique by ID
  BreathingTechnique? getTechniqueById(String id) {
    try {
      return techniques.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get recommended technique based on need
  BreathingTechnique getRecommendedTechnique(String need) {
    switch (need.toLowerCase()) {
      case 'anxiety':
      case 'stress':
        return techniques.firstWhere((t) => t.id == 'extended_exhale');
      case 'sleep':
        return techniques.firstWhere((t) => t.id == '4_7_8');
      case 'focus':
        return techniques.firstWhere((t) => t.id == 'box');
      case 'energy':
        return techniques.firstWhere((t) => t.id == 'energize');
      default:
        return techniques.firstWhere((t) => t.id == 'deep_calm');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

