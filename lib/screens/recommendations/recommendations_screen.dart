import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/recommendation.dart';
import '../../services/recommendation_service.dart';
import '../../services/mood_service.dart';
import '../../services/auth_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final recommendationService = context.read<RecommendationService>();
    final moodService = context.read<MoodService>();
    final authService = context.read<AuthService>();

    final userProfile = {
      'interests': authService.currentUserModel?.interests ?? [],
      'age': authService.currentUserModel?.age,
      'location': 'New York, NY', // Could be from device location
    };

    await recommendationService.fetchRecommendations(
      moodService.todaysMood,
      userProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendationService = context.watch<RecommendationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
          ),
        ],
      ),
      body: recommendationService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendationService.recommendations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRecommendations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recommendationService.recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation =
                          recommendationService.recommendations[index];
                      return _buildRecommendationCard(recommendation);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No recommendations yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your mood check-in to get personalized recommendations',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadRecommendations,
            child: const Text('Load Recommendations'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Recommendation recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _handleRecommendationTap(recommendation),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (if available)
            if (recommendation.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: recommendation.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recommendation.typeIcon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recommendation.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    recommendation.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  // Subtitle
                  if (recommendation.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      recommendation.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],

                  // Description
                  if (recommendation.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      recommendation.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Action button
                  if (recommendation.actionUrl != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleRecommendationTap(recommendation),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(_getActionLabel(recommendation.type)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActionLabel(RecommendationType type) {
    switch (type) {
      case RecommendationType.movie:
        return 'View Details';
      case RecommendationType.book:
        return 'Learn More';
      case RecommendationType.video:
        return 'Watch Video';
      case RecommendationType.therapist:
        return 'View Profile';
      case RecommendationType.meditation:
        return 'Start Session';
      case RecommendationType.music:
        return 'Listen Now';
      case RecommendationType.workout:
        return 'Start Workout';
      case RecommendationType.event:
        return 'View Event';
      default:
        return 'Open';
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

