import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood_entry.dart';
import '../../services/mood_service.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

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
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Check-in complete',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Great job on checking in today',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Daily Check-In'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 48),

            // Mood selection
            Text(
              'Select your mood',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            _buildMoodSelector(),
            const SizedBox(height: 48),

            // Mood rating slider
            if (_selectedMood != null) ...[
              Text(
                'Intensity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: List.generate(5, (index) {
                  final rating = index + 1;
                  final isSelected = _moodRating == rating;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _moodRating = rating),
                      child: Container(
                        height: 48,
                        margin: EdgeInsets.only(
                          right: index < 4 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.grey[300]
                              : Colors.grey[200],
                          border: Border.all(
                            color: isSelected
                                ? Colors.grey[400]!
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mild',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Intense',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],

            // Optional notes
            Text(
              'Notes (optional)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getRandomPrompt(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts here...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text(
                        'Complete Check-In',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
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

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: moods.map((mood) {
        final entry = MoodEntry(
          id: '',
          userId: '',
          timestamp: DateTime.now(),
          mood: mood,
          moodRating: 3,
        );

        final isSelected = _selectedMood == mood;

        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.grey[300]
                  : Colors.grey[200],
              border: Border.all(
                color: isSelected
                    ? Colors.grey[400]!
                    : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                entry.moodLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
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

