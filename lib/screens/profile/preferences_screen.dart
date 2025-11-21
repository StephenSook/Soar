import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isSaving = false;

  // Personalization data
  Set<String> _selectedInterests = {};
  Set<String> _selectedMentalHealthAreas = {};
  Map<String, bool> _contentPreferences = {};
  TimeOfDay _checkInTime = const TimeOfDay(hour: 9, minute: 0);

  final List<Map<String, dynamic>> _interestOptions = [
    {
      'label': 'Meditation & Mindfulness',
      'icon': Icons.self_improvement_rounded,
      'value': 'meditation'
    },
    {'label': 'Journaling', 'icon': Icons.book_rounded, 'value': 'journaling'},
    {
      'label': 'Stress Relief',
      'icon': Icons.spa_rounded,
      'value': 'stress_relief'
    },
    {
      'label': 'Better Sleep',
      'icon': Icons.bedtime_rounded,
      'value': 'sleep'
    },
    {
      'label': 'Physical Wellness',
      'icon': Icons.fitness_center_rounded,
      'value': 'fitness'
    },
    {
      'label': 'Social Connection',
      'icon': Icons.people_rounded,
      'value': 'social'
    },
    {
      'label': 'Personal Growth',
      'icon': Icons.trending_up_rounded,
      'value': 'growth'
    },
    {
      'label': 'Breathing Exercises',
      'icon': Icons.air_rounded,
      'value': 'breathing'
    },
  ];

  final List<Map<String, dynamic>> _mentalHealthOptions = [
    {
      'label': 'Anxiety',
      'icon': Icons.psychology_rounded,
      'value': 'anxiety'
    },
    {
      'label': 'Depression',
      'icon': Icons.favorite_rounded,
      'value': 'depression'
    },
    {
      'label': 'Stress Management',
      'icon': Icons.trending_down_rounded,
      'value': 'stress'
    },
    {
      'label': 'Sleep Issues',
      'icon': Icons.nightlight_rounded,
      'value': 'sleep_issues'
    },
    {
      'label': 'Focus & ADHD',
      'icon': Icons.center_focus_strong_rounded,
      'value': 'adhd'
    },
    {'label': 'Grief & Loss', 'icon': Icons.cloud_rounded, 'value': 'grief'},
    {
      'label': 'Relationship Issues',
      'icon': Icons.volunteer_activism_rounded,
      'value': 'relationships'
    },
    {
      'label': 'General Wellness',
      'icon': Icons.wb_sunny_rounded,
      'value': 'general'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUserModel;

    if (user != null) {
      setState(() {
        _selectedInterests = user.interests.toSet();
        _selectedMentalHealthAreas = user.mentalHealthHistory.toSet();
        _contentPreferences = Map.from(user.contentPreferences);

        // Parse check-in time
        if (user.moodCheckInTime != null) {
          final parts = user.moodCheckInTime!.split(':');
          if (parts.length == 2) {
            _checkInTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 9,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }

        // Ensure all content preferences exist
        _contentPreferences.putIfAbsent('podcasts', () => true);
        _contentPreferences.putIfAbsent('articles', () => true);
        _contentPreferences.putIfAbsent('videos', () => true);
        _contentPreferences.putIfAbsent('meditation', () => true);
        _contentPreferences.putIfAbsent('journaling', () => true);

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      final authService = context.read<AuthService>();

      // Format check-in time
      final checkInTimeString =
          '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}';

      await authService.updateUserProfile(
        interests: _selectedInterests.toList(),
        mentalHealthHistory: _selectedMentalHealthAreas.toList(),
        contentPreferences: _contentPreferences,
        moodCheckInTime: checkInTimeString,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Preferences saved successfully!'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Preferences'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePreferences,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Interests'),
            Tab(text: 'Focus Areas'),
            Tab(text: 'Content'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInterestsTab(),
                _buildMentalHealthTab(),
                _buildContentTab(),
              ],
            ),
    );
  }

  Widget _buildInterestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you interested in?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply to personalize your experience.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _interestOptions.map((option) {
              final isSelected = _selectedInterests.contains(option['value']);
              return _buildSelectionChip(
                label: option['label'] as String,
                icon: option['icon'] as IconData,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(option['value']);
                    } else {
                      _selectedInterests.add(option['value'] as String);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like support with?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us provide relevant content and resources.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _mentalHealthOptions.map((option) {
              final isSelected =
                  _selectedMentalHealthAreas.contains(option['value']);
              return _buildSelectionChip(
                label: option['label'] as String,
                icon: option['icon'] as IconData,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMentalHealthAreas.remove(option['value']);
                    } else {
                      _selectedMentalHealthAreas
                          .add(option['value'] as String);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose what types of content you\'d like to receive.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildPreferenceCard(
            'Daily Podcasts',
            'AI-generated podcasts tailored to your mood',
            Icons.headset_rounded,
            _contentPreferences['podcasts'] ?? true,
            (value) {
              setState(() {
                _contentPreferences['podcasts'] = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildPreferenceCard(
            'Articles & Reading',
            'Curated articles on mental wellness',
            Icons.article_rounded,
            _contentPreferences['articles'] ?? true,
            (value) {
              setState(() {
                _contentPreferences['articles'] = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildPreferenceCard(
            'Videos & Films',
            'Movie and video recommendations',
            Icons.movie_rounded,
            _contentPreferences['videos'] ?? true,
            (value) {
              setState(() {
                _contentPreferences['videos'] = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildPreferenceCard(
            'Guided Meditation',
            'Meditation sessions and exercises',
            Icons.self_improvement_rounded,
            _contentPreferences['meditation'] ?? true,
            (value) {
              setState(() {
                _contentPreferences['meditation'] = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildPreferenceCard(
            'Journaling Prompts',
            'Daily prompts for reflection',
            Icons.edit_note_rounded,
            _contentPreferences['journaling'] ?? true,
            (value) {
              setState(() {
                _contentPreferences['journaling'] = value;
              });
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Check-in Reminder',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your daily reminder time.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.2),
                        AppTheme.secondaryColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reminder Time',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _checkInTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppTheme.primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() {
                        _checkInTime = time;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : AppTheme.textPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.2),
                AppTheme.secondaryColor.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        activeColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

