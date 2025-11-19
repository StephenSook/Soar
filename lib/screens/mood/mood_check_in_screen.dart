import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood_entry.dart';
import '../../services/mood_service.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  MoodType? _selectedMood;
  int _moodRating = 3;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitCheckIn() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final moodService = context.read<MoodService>();
      await moodService.submitMoodCheckIn(
        mood: _selectedMood!,
        moodRating: _moodRating,
        journalNote: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Check-In Complete!'),
            content: const Text(
              'Great job! Your apps are now unlocked. Keep up the good work!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to home
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mood selection
            Text(
              'Select your mood:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildMoodSelector(),
            const SizedBox(height: 32),

            // Mood rating slider
            if (_selectedMood != null) ...[
              Text(
                'How intense is this feeling? (1-5)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Slider(
                value: _moodRating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _moodRating.toString(),
                onChanged: (value) {
                  setState(() => _moodRating = value.toInt());
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mild', style: Theme.of(context).textTheme.bodySmall),
                  Text('Intense', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Optional notes
            Text(
              'Anything you\'d like to note? (Optional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getRandomPrompt(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCheckIn,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Complete Check-In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      MoodType.veryHappy,
      MoodType.happy,
      MoodType.neutral,
      MoodType.sad,
      MoodType.verySad,
      MoodType.anxious,
      MoodType.stressed,
      MoodType.calm,
      MoodType.energetic,
      MoodType.tired,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: moods.map((mood) {
        final entry = MoodEntry(
          id: '',
          userId: '',
          timestamp: DateTime.now(),
          mood: mood,
          moodRating: 3,
        );

        final isSelected = _selectedMood == mood;

        return InkWell(
          onTap: () => setState(() => _selectedMood = mood),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  entry.moodEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.moodLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getRandomPrompt() {
    final prompts = AppConstants.journalPrompts;
    return prompts[DateTime.now().day % prompts.length];
  }
}

