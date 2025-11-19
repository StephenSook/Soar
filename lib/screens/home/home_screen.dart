import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/mood_service.dart';
import '../mood/mood_check_in_screen.dart';
import '../recommendations/recommendations_screen.dart';
import '../podcast/podcast_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';

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
      // Show mood check-in prompt
      Future.delayed(const Duration(seconds: 1), () {
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
      builder: (context) => AlertDialog(
        title: const Text('Daily Check-In'),
        content: const Text(
          'Time to check in with yourself! Your selected apps will remain locked until you complete your mood check-in.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.headset_outlined),
            selectedIcon: Icon(Icons.headset),
            label: 'Podcast',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, ${user?.displayName ?? "there"}! 👋',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood check-in status card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            moodService.hasCheckedInToday
                                ? Icons.check_circle
                                : Icons.pending,
                            color: moodService.hasCheckedInToday
                                ? Colors.green
                                : Colors.orange,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  moodService.hasCheckedInToday
                                      ? 'Check-in Complete! ✨'
                                      : 'Ready to Check In?',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  moodService.hasCheckedInToday
                                      ? 'You\'re doing great!'
                                      : 'Take a moment for yourself',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!moodService.hasCheckedInToday) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Mood streak card
              if (moodService.moodHistory.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Your Progress',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildMoodStats(moodService),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Quick actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              _buildQuickActions(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodStats(MoodService moodService) {
    final stats = moodService.getMoodStatistics();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              '${stats['streak']}',
              'Day Streak',
              Icons.local_fire_department,
              Colors.orange,
            ),
            _buildStatItem(
              '${stats['totalEntries']}',
              'Check-ins',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatItem(
              '${(stats['averageRating'] as double).toStringAsFixed(1)}',
              'Avg Mood',
              Icons.mood,
              Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildQuickActionCard(
            'Meditation',
            Icons.self_improvement,
            Colors.purple,
            () {
              // TODO: Navigate to meditation
            },
          ),
          _buildQuickActionCard(
            'Journal',
            Icons.book,
            Colors.blue,
            () {
              // TODO: Navigate to journal
            },
          ),
          _buildQuickActionCard(
            'Breathe',
            Icons.air,
            Colors.teal,
            () {
              // TODO: Navigate to breathing exercise
            },
          ),
          _buildQuickActionCard(
            'Crisis Help',
            Icons.support_agent,
            Colors.red,
            () {
              // TODO: Show crisis resources
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

