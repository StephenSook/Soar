import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Personalization data
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedMentalHealthAreas = {};
  final Map<String, bool> _contentPreferences = {
    'podcasts': true,
    'articles': true,
    'videos': true,
    'meditation': true,
    'journaling': true,
  };
  TimeOfDay _checkInTime = const TimeOfDay(hour: 9, minute: 0);
  final Set<String> _selectedBlockedApps = {};

  final List<Map<String, dynamic>> _interestOptions = [
    {'label': 'Meditation & Mindfulness', 'icon': Icons.self_improvement_rounded, 'value': 'meditation'},
    {'label': 'Journaling', 'icon': Icons.book_rounded, 'value': 'journaling'},
    {'label': 'Stress Relief', 'icon': Icons.spa_rounded, 'value': 'stress_relief'},
    {'label': 'Better Sleep', 'icon': Icons.bedtime_rounded, 'value': 'sleep'},
    {'label': 'Physical Wellness', 'icon': Icons.fitness_center_rounded, 'value': 'fitness'},
    {'label': 'Social Connection', 'icon': Icons.people_rounded, 'value': 'social'},
    {'label': 'Personal Growth', 'icon': Icons.trending_up_rounded, 'value': 'growth'},
    {'label': 'Breathing Exercises', 'icon': Icons.air_rounded, 'value': 'breathing'},
  ];

  final List<Map<String, dynamic>> _mentalHealthOptions = [
    {'label': 'Anxiety', 'icon': Icons.psychology_rounded, 'value': 'anxiety'},
    {'label': 'Depression', 'icon': Icons.favorite_rounded, 'value': 'depression'},
    {'label': 'Stress Management', 'icon': Icons.trending_down_rounded, 'value': 'stress'},
    {'label': 'Sleep Issues', 'icon': Icons.nightlight_rounded, 'value': 'sleep_issues'},
    {'label': 'Focus & ADHD', 'icon': Icons.center_focus_strong_rounded, 'value': 'adhd'},
    {'label': 'Grief & Loss', 'icon': Icons.cloud_rounded, 'value': 'grief'},
    {'label': 'Relationship Issues', 'icon': Icons.volunteer_activism_rounded, 'value': 'relationships'},
    {'label': 'General Wellness', 'icon': Icons.wb_sunny_rounded, 'value': 'general'},
  ];

  final List<Map<String, String>> _commonApps = [
    {'name': 'Instagram', 'package': 'com.instagram.android'},
    {'name': 'TikTok', 'package': 'com.zhiliaoapp.musically'},
    {'name': 'Twitter/X', 'package': 'com.twitter.android'},
    {'name': 'Facebook', 'package': 'com.facebook.katana'},
    {'name': 'YouTube', 'package': 'com.google.android.youtube'},
    {'name': 'Snapchat', 'package': 'com.snapchat.android'},
    {'name': 'Reddit', 'package': 'com.reddit.frontpage'},
    {'name': 'Netflix', 'package': 'com.netflix.mediaclient'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitPersonalization();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitPersonalization() async {
    setState(() => _isSubmitting = true);

    try {
      final authService = context.read<AuthService>();
      
      // Format check-in time
      final checkInTimeString = '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}';

      await authService.updateUserProfile(
        interests: _selectedInterests.toList(),
        mentalHealthHistory: _selectedMentalHealthAreas.toList(),
        contentPreferences: _contentPreferences,
        moodCheckInTime: checkInTimeString,
      );

      // Save blocked apps to SharedPreferences (handled by app blocking service)
      // This would integrate with the actual app blocking mechanism

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Skip personalization
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text('Skip', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildInterestsPage(),
                _buildMentalHealthPage(),
                _buildContentPreferencesPage(),
                _buildCheckInTimePage(),
                _buildBlockedAppsPage(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_currentPage < 4 ? 'Next' : 'Complete'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'What are you interested in?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select all that apply. This helps us personalize your experience.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 32),
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

  Widget _buildMentalHealthPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'What would you like support with?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your selections help us provide relevant content and resources.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _mentalHealthOptions.map((option) {
              final isSelected = _selectedMentalHealthAreas.contains(option['value']);
              return _buildSelectionChip(
                label: option['label'] as String,
                icon: option['icon'] as IconData,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMentalHealthAreas.remove(option['value']);
                    } else {
                      _selectedMentalHealthAreas.add(option['value'] as String);
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

  Widget _buildContentPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Content preferences',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'What types of content would you like to receive?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 32),
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
        ],
      ),
    );
  }

  Widget _buildCheckInTimePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Daily check-in reminder',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'When would you like us to remind you to check in with yourself?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${_checkInTime.hour.toString().padLeft(2, '0')}:${_checkInTime.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontSize: 56,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
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
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Change Time'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.infoColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'You can change this anytime in your profile settings.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimaryColor,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedAppsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'App blocking (optional)',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select apps that will be locked until you complete your daily check-in.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 32),
          ..._commonApps.map((app) {
            final isSelected = _selectedBlockedApps.contains(app['package']);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedBlockedApps.add(app['package']!);
                    } else {
                      _selectedBlockedApps.remove(app['package']);
                    }
                  });
                },
                title: Text(
                  app['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                activeColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Note: App blocking requires additional permissions and may not work on all devices. You can skip this step and set it up later.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimaryColor,
                        ),
                  ),
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

