import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/recommendation.dart';
import '../../services/recommendation_service.dart';
import '../../services/mood_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRecommendations();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    final recommendationService = context.read<RecommendationService>();
    final moodService = context.read<MoodService>();
    final authService = context.read<AuthService>();

    final userProfile = {
      'interests': authService.currentUserModel?.interests ?? [],
      'age': authService.currentUserModel?.age,
      'location': 'New York, NY',
    };

    await recommendationService.fetchRecommendations(
      moodService.todaysMood,
      userProfile,
    );
  }

  Future<void> _regenerateRecommendations(RecommendationType type) async {
    final recommendationService = context.read<RecommendationService>();
    final moodService = context.read<MoodService>();
    final authService = context.read<AuthService>();

    final userProfile = {
      'interests': authService.currentUserModel?.interests ?? [],
      'age': authService.currentUserModel?.age,
      'location': 'New York, NY',
    };

    await recommendationService.regenerateRecommendations(
      type,
      moodService.todaysMood,
      userProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendationService = context.watch<RecommendationService>();
    final groupedRecs = recommendationService.recommendations.isNotEmpty
        ? _groupRecommendationsByType(recommendationService.recommendations)
        : <RecommendationType, List<Recommendation>>{};

    if (_tabController == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Recommendations'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Recommendations'),
        bottom: TabBar(
          controller: _tabController!,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'Books'),
            Tab(text: 'Videos'),
            Tab(text: 'Therapists'),
          ],
        ),
      ),
      body: recommendationService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendationService.recommendations.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                  controller: _tabController!,
                  children: [
                    _buildTabView(RecommendationType.movie, groupedRecs),
                    _buildTabView(RecommendationType.book, groupedRecs),
                    _buildTabView(RecommendationType.video, groupedRecs),
                    _buildTabView(RecommendationType.therapist, groupedRecs),
                  ],
                ),
    );
  }

  Map<RecommendationType, List<Recommendation>> _groupRecommendationsByType(
    List<Recommendation> recommendations,
  ) {
    final Map<RecommendationType, List<Recommendation>> grouped = {};

    for (var rec in recommendations) {
      if (!grouped.containsKey(rec.type)) {
        grouped[rec.type] = [];
      }
      grouped[rec.type]!.add(rec);
    }

    return grouped;
  }

  String _getTypeLabel(RecommendationType type) {
    switch (type) {
      case RecommendationType.movie:
        return 'Movies';
      case RecommendationType.book:
        return 'Books';
      case RecommendationType.video:
        return 'Videos';
      case RecommendationType.therapist:
        return 'Therapists';
      case RecommendationType.meditation:
        return 'Meditation';
      case RecommendationType.journalPrompt:
        return 'Journal Prompts';
      case RecommendationType.music:
        return 'Music';
      case RecommendationType.affirmation:
        return 'Affirmations';
      case RecommendationType.workout:
        return 'Workouts';
      case RecommendationType.nutrition:
        return 'Nutrition';
      case RecommendationType.event:
        return 'Events';
    }
  }

  Widget _buildTabView(RecommendationType type, Map<RecommendationType, List<Recommendation>> groupedRecs) {
    final recommendations = groupedRecs[type] ?? [];
    final recommendationService = context.watch<RecommendationService>();
    final canRegenerate = type == RecommendationType.movie || 
                         type == RecommendationType.video || 
                         type == RecommendationType.book;

    if (recommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No ${_getTypeLabel(type)} Yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for personalized ${_getTypeLabel(type).toLowerCase()}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length + (canRegenerate ? 1 : 0),
        itemBuilder: (context, index) {
          // Show generate new button at the top for movies, videos, and books
          if (canRegenerate && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton.icon(
                onPressed: recommendationService.isLoading
                    ? null
                    : () => _regenerateRecommendations(type),
                icon: recommendationService.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  recommendationService.isLoading
                      ? 'Generating...'
                      : 'Generate New ${_getTypeLabel(type)}',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            );
          }

          // Adjust index if generate button is shown
          final recommendationIndex = canRegenerate ? index - 1 : index;
          final recommendation = recommendations[recommendationIndex];
          
          // Use special large card layout for videos
          if (recommendation.type == RecommendationType.video) {
            return _buildVideoCard(
              recommendation,
              recommendationIndex == recommendations.length - 1,
            );
          }
          return _buildRecommendationCard(
            recommendation,
            recommendationIndex == recommendations.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Recommendation> recommendations,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 48),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // Horizontal scrolling list
            SizedBox(
              height: 380,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  return _buildRecommendationCard(
                    recommendations[index],
                    index == recommendations.length - 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Recommendation recommendation, bool isLast) {
    // Don't show images for books
    final showImage = recommendation.type != RecommendationType.book &&
        recommendation.imageUrl != null &&
        recommendation.imageUrl!.isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      color: Colors.grey[100],
      child: InkWell(
        onTap: () => _handleRecommendationTap(recommendation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (skip for books)
              if (showImage) ...[
                Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: recommendation.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          _getTypeIcon(recommendation.type),
                          color: Colors.grey[600],
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      recommendation.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtitle
                    if (recommendation.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        recommendation.subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Description
                    if (recommendation.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        recommendation.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black87,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Action
                    if (recommendation.actionUrl != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _handleRecommendationTap(recommendation),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getActionLabel(recommendation.type),
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(Recommendation recommendation, bool isLast) {
    // Calculate thumbnail size based on screen width minus padding
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 32.0; // 16px padding on each side
    final availableWidth = screenWidth - padding;
    final thumbnailSize = availableWidth * 0.4; // Smaller thumbnail size

    return Card(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      color: Colors.grey[100],
      child: InkWell(
        onTap: () => _handleRecommendationTap(recommendation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail on top
              if (recommendation.imageUrl != null && recommendation.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: thumbnailSize,
                    height: thumbnailSize,
                    color: Colors.grey[300],
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: recommendation.imageUrl!,
                          fit: BoxFit.cover,
                          width: thumbnailSize,
                          height: thumbnailSize,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.video_library,
                              color: Colors.grey[600],
                              size: 40,
                            ),
                          ),
                        ),
                        // Play button overlay
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (recommendation.imageUrl != null && recommendation.imageUrl!.isNotEmpty)
                const SizedBox(height: 12),
              // Description and link below thumbnail
              if (recommendation.description != null) ...[
                Text(
                  recommendation.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              // Action link
              if (recommendation.actionUrl != null)
                TextButton(
                  onPressed: () => _handleRecommendationTap(recommendation),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getActionLabel(recommendation.type),
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No recommendations yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Complete your mood check-in to get personalized recommendations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadRecommendations,
              child: const Text('Load Recommendations'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.movie:
        return Icons.movie;
      case RecommendationType.book:
        return Icons.book;
      case RecommendationType.video:
        return Icons.video_library;
      case RecommendationType.therapist:
        return Icons.medical_services;
      case RecommendationType.meditation:
        return Icons.self_improvement;
      case RecommendationType.music:
        return Icons.music_note;
      case RecommendationType.workout:
        return Icons.fitness_center;
      case RecommendationType.nutrition:
        return Icons.restaurant;
      case RecommendationType.affirmation:
        return Icons.favorite;
      case RecommendationType.journalPrompt:
        return Icons.edit;
      case RecommendationType.event:
        return Icons.event;
    }
  }

  String _getActionLabel(RecommendationType type) {
    switch (type) {
      case RecommendationType.movie:
        return 'View Details';
      case RecommendationType.book:
        return 'Learn More';
      case RecommendationType.video:
        return 'Watch';
      case RecommendationType.therapist:
        return 'View Profile';
      case RecommendationType.meditation:
        return 'Start';
      case RecommendationType.music:
        return 'Listen';
      case RecommendationType.workout:
        return 'Start';
      case RecommendationType.event:
        return 'View Event';
      default:
        return 'Learn More';
    }
  }

  Future<void> _handleRecommendationTap(Recommendation recommendation) async {
    if (recommendation.actionUrl != null) {
      final url = Uri.parse(recommendation.actionUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link')),
          );
        }
      }
    }
  }
}
