import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/breathing_service.dart';
import 'dart:math' as math;

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  BreathingTechnique? _selectedTechnique;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breathingService = context.watch<BreathingService>();

    if (breathingService.isActive) {
      return _buildActiveExerciseScreen(breathingService);
    }

    if (_selectedTechnique != null) {
      return _buildTechniqueDetailScreen(_selectedTechnique!);
    }

    return _buildTechniqueListScreen();
  }

  Widget _buildTechniqueListScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Breathing Exercises', style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Breathe Better, Feel Better',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a breathing technique to calm your mind and body',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ...BreathingService.techniques.map((technique) {
            return _buildTechniqueCard(technique);
          }),
        ],
      ),
    );
  }

  Widget _buildTechniqueCard(BreathingTechnique technique) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTechnique = technique;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.air,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technique.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${technique.totalDuration ~/ 60} min ${technique.totalDuration % 60} sec',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                technique.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  technique.benefit,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechniqueDetailScreen(BreathingTechnique technique) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              _selectedTechnique = null;
            });
          },
        ),
        title: Text(technique.name, style: const TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.air,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    technique.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      technique.benefit,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.black87,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    technique.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildPhasePreview(technique),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<BreathingService>().start(technique);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Start Exercise',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhasePreview(BreathingTechnique technique) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How it works',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '${technique.cycles} cycles of:',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            ...technique.phases.map((phase) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _getPhaseIcon(phase.name),
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${phase.instruction} (${phase.duration}s)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveExerciseScreen(BreathingService service) {
    final technique = service.currentTechnique!;
    final phase = service.currentPhase!;
    
    // Update animation based on phase
    if (phase.name == 'Inhale') {
      _animationController.duration = Duration(seconds: phase.duration);
      _animationController.forward(from: 0);
    } else if (phase.name == 'Exhale') {
      _animationController.duration = Duration(seconds: phase.duration);
      _animationController.reverse(from: 1);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => _confirmExit(service),
        ),
        title: Text(technique.name, style: const TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Cycles remaining
            Text(
              'Cycle ${service.currentCycle + 1} of ${technique.cycles}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            // Animated breathing circle
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 100 + (150 * _animationController.value),
                  height: 100 + (150 * _animationController.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(
                      0.2 + (0.3 * _animationController.value),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.air,
                      size: 60 + (40 * _animationController.value),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            // Phase instruction
            Text(
              phase.instruction,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                service.phaseTimeRemaining.toString(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
            const Spacer(),
            // Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: ElevatedButton(
                onPressed: () => _confirmExit(service),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('End Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPhaseIcon(String phaseName) {
    switch (phaseName.toLowerCase()) {
      case 'inhale':
        return Icons.arrow_upward;
      case 'exhale':
        return Icons.arrow_downward;
      case 'hold':
        return Icons.pause;
      default:
        return Icons.circle;
    }
  }

  void _confirmExit(BreathingService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Exercise?'),
        content: const Text('Are you sure you want to stop this breathing exercise?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              service.stop();
              _animationController.stop();
              Navigator.pop(context);
            },
            child: const Text('End Exercise'),
          ),
        ],
      ),
    );
  }
}

