import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/meditation_service.dart';
import 'dart:math' as math;

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  MeditationSession? _selectedSession;

  @override
  Widget build(BuildContext context) {
    final meditationService = context.watch<MeditationService>();

    if (meditationService.isPlaying || meditationService.isPaused) {
      return _buildActiveSessionScreen(meditationService);
    }

    if (_selectedSession != null) {
      return _buildSessionDetailScreen(_selectedSession!);
    }

    return _buildSessionListScreen();
  }

  Widget _buildSessionListScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose Your Practice',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a meditation session that fits your needs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          _buildCategorySection('Guided Meditations'),
          ...MeditationService.sessions
              .where((s) => s.category == 'guided' || s.category == 'body-scan')
              .map((session) => _buildSessionCard(session)),
          const SizedBox(height: 16),
          _buildCategorySection('Silent Practice'),
          ...MeditationService.sessions
              .where((s) => s.category == 'silent')
              .map((session) => _buildSessionCard(session)),
          const SizedBox(height: 16),
          _buildCategorySection('Breathing Focus'),
          ...MeditationService.sessions
              .where((s) => s.category == 'breathing')
              .map((session) => _buildSessionCard(session)),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSessionCard(MeditationSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            _getSessionIcon(session.category),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(session.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(session.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${session.durationMinutes} min',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          setState(() {
            _selectedSession = session;
          });
        },
      ),
    );
  }

  Widget _buildSessionDetailScreen(MeditationSession session) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedSession = null;
            });
          },
        ),
        title: Text(session.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _getSessionIcon(session.category),
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    session.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${session.durationMinutes} minutes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    session.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildTips(session),
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
                  context.read<MeditationService>().startSession(session);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Begin Meditation',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionScreen(MeditationService service) {
    final session = service.currentSession!;
    final minutes = service.elapsed.inMinutes;
    final seconds = service.elapsed.inSeconds % 60;
    final totalMinutes = service.duration.inMinutes;
    final totalSeconds = service.duration.inSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(service),
        ),
        title: Text(session.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Animated progress circle
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(250, 250),
                    painter: _MeditationProgressPainter(
                      progress: service.progress,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'of $totalMinutes:${totalSeconds.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              service.isPaused ? 'Paused' : 'Breathe and relax...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 64,
                  icon: Icon(
                    service.isPaused ? Icons.play_circle_filled : Icons.pause_circle_filled,
                  ),
                  onPressed: () {
                    if (service.isPaused) {
                      service.resume();
                    } else {
                      service.pause();
                    }
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 64,
                  icon: const Icon(Icons.stop_circle),
                  onPressed: () => _confirmExit(service),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTips(MeditationSession session) {
    List<String> tips = [
      'Find a quiet, comfortable place',
      'Sit with your back straight',
      'Close your eyes or soften your gaze',
      'Let thoughts come and go without judgment',
    ];

    if (session.category == 'silent') {
      tips.add('Focus on your breath or a chosen anchor');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Meditation Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 18)),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  IconData _getSessionIcon(String category) {
    switch (category) {
      case 'guided':
        return Icons.hearing;
      case 'body-scan':
        return Icons.accessibility_new;
      case 'silent':
        return Icons.self_improvement;
      case 'breathing':
        return Icons.air;
      default:
        return Icons.spa;
    }
  }

  void _confirmExit(MeditationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to stop this meditation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              service.stop();
              Navigator.pop(context);
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}

class _MeditationProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MeditationProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_MeditationProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

