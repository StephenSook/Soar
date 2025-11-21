import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/mood_service.dart';
import '../../utils/theme.dart';
import '../../utils/top_navigation.dart';
import '../mood/mood_check_in_screen.dart';
import '../recommendations/recommendations_screen.dart';
import '../podcast/podcast_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';
import '../journal/journal_screen.dart';
import '../meditation/meditation_screen.dart';
import '../breathing/breathing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    RecommendationsScreen(),
    PodcastScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkMoodStatus();
  }

  Future<void> _checkMoodStatus() async {
    final moodService = context.read<MoodService>();
    await moodService.checkTodaysCheckIn();

    if (!moodService.hasCheckedInToday && mounted) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _showMoodCheckInPrompt();
        }
      });
    }
  }

  void _showMoodCheckInPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Daily Check-In',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Time to check in with yourself.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodCheckInScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Check In Now',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          TopNavigation(
            currentIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final moodService = context.read<MoodService>();
    await moodService.loadMoodHistory();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final moodService = context.watch<MoodService>();
    final user = authService.currentUserModel;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Hero image section - minimal and prominent
          SliverToBoxAdapter(
            child: Container(
              height: 400,
              margin: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'soar-images/lakeside-pic.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.cardColor,
                        );
                      },
                    ),
                    // Minimal gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    // Minimal text overlay
                    Positioned(
                      bottom: 32,
                      left: 32,
                      right: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.displayName ?? "there"}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getGreetingMessage(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Mood check-in card - minimal
                _buildMoodCheckInCard(moodService),

                // Mood stats
                if (moodService.moodHistory.isNotEmpty) ...[
                  const SizedBox(height: 48),
                  Text(
                    'Your Progress',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textPrimaryColor,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildMoodStatsCard(moodService),
                ],

                const SizedBox(height: 48),

                // Wellness tools section
                Text(
                  'Wellness Tools',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                const SizedBox(height: 24),
                _buildWellnessTools(),

                const SizedBox(height: 48),

                // Daily inspiration with image - minimal
                _buildInspirationSection(),

                const SizedBox(height: 64),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Widget _buildMoodCheckInCard(MoodService moodService) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: moodService.hasCheckedInToday
            ? AppTheme.cardColor
            : AppTheme.surfaceColor,
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            moodService.hasCheckedInToday
                ? 'All set for today'
                : 'Ready to check in?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            moodService.hasCheckedInToday
                ? 'You\'ve completed your daily check-in'
                : 'Take a moment for yourself',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          if (!moodService.hasCheckedInToday) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodCheckInScreen(),
                  ),
                );
              },
              child: const Text('Check In Now'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodStatsCard(MoodService moodService) {
    final stats = moodService.getMoodStatistics();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '${stats['streak']}',
            'Day Streak',
          ),
          Container(
            height: 40,
            width: 1,
            color: AppTheme.dividerColor,
          ),
          _buildStatItem(
            '${stats['totalEntries']}',
            'Check-ins',
          ),
          Container(
            height: 40,
            width: 1,
            color: AppTheme.dividerColor,
          ),
          _buildStatItem(
            '${(stats['averageRating'] as double).toStringAsFixed(1)}',
            'Avg Mood',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildWellnessTools() {
    return Row(
      children: [
        Expanded(
          child: _buildToolCard(
            'Meditation',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MeditationScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildToolCard(
            'Journal',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildToolCard(
            'Breathe',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BreathingScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolCard(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          border: Border.all(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInspirationSection() {
    final inspirations = [
      {
        'image': 'soar-images/beach.jpg',
        'quote': 'Take a deep breath.',
      },
      {
        'image': 'soar-images/landscape1.jpg',
        'quote': 'Progress, not perfection.',
      },
      {
        'image': 'soar-images/landscape2.jpg',
        'quote': 'Your mental health matters.',
      },
    ];

    final inspiration = inspirations[DateTime.now().day % inspirations.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Inspiration',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 500,
          child: Stack(
            children: [
              Image.asset(
                inspiration['image'] as String,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.cardColor,
                  );
                },
              ),
              // Dark overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 32,
                right: 32,
                child: Text(
                  inspiration['quote'] as String,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.4,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
