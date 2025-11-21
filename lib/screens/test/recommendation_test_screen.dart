import 'package:flutter/material.dart';
import '../../models/mood_entry.dart';
import '../../services/recommendation_service_test_helper.dart';

/// Test screen for Movie and Book Recommendations
/// 
/// This screen allows you to test the recommendation features
/// with different moods and see the results
class RecommendationTestScreen extends StatefulWidget {
  const RecommendationTestScreen({super.key});

  @override
  State<RecommendationTestScreen> createState() => _RecommendationTestScreenState();
}

class _RecommendationTestScreenState extends State<RecommendationTestScreen> {
  final RecommendationTestHelper _testHelper = RecommendationTestHelper();
  bool _isLoading = false;
  Map<String, dynamic>? _testResults;
  String _statusMessage = 'Tap "Run Tests" to start';

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Running tests...';
      _testResults = null;
    });

    try {
      final results = await _testHelper.testAllFeatures();
      
      setState(() {
        _testResults = results;
        _statusMessage = 'Tests completed successfully!';
        _isLoading = false;
      });

      // Print to console for debugging
      _testHelper.printResults(results);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error running tests: $e';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendation Tests'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.science, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      'Movie & Book Recommendations Test',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tests TMDB and Google Books API integration',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Run Tests Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runTests,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isLoading ? 'Running Tests...' : 'Run Tests'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Status Card
            Card(
              color: _testResults != null ? Colors.green.shade50 : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _testResults != null ? Icons.check_circle : Icons.info,
                      color: _testResults != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results Section
            if (_testResults != null) ...[
              _buildMovieResults(),
              const SizedBox(height: 16),
              _buildBookResults(),
            ],

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Test Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.blue.shade900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('This test will:'),
                    const SizedBox(height: 8),
                    const Text('• Fetch movies for Happy, Sad, and Anxious moods'),
                    const Text('• Fetch books for Stressed, Calm, and Tired moods'),
                    const Text('• Verify API connectivity'),
                    const Text('• Test error handling and fallbacks'),
                    const SizedBox(height: 12),
                    const Text(
                      'Check the console/debug output for detailed logs.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieResults() {
    final movies = _testResults!['movies'] as Map<String, dynamic>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎬', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'Movie Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            ...movies.entries.map((entry) {
              final moodName = entry.key.split('.').last;
              final data = entry.value as Map<String, dynamic>;
              final isSuccess = data['success'] == true;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: isSuccess ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          moodName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (isSuccess)
                          Text(
                            '${data['count']} movies',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    if (isSuccess && data['sample_titles'] != null) ...[
                      const SizedBox(height: 4),
                      ...((data['sample_titles'] as List).map((title) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 28, top: 2),
                          child: Text(
                            '• $title',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        );
                      })),
                    ],
                    if (!isSuccess)
                      Padding(
                        padding: const EdgeInsets.only(left: 28, top: 4),
                        child: Text(
                          'Error: ${data['error']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
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

  Widget _buildBookResults() {
    final books = _testResults!['books'] as Map<String, dynamic>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📚', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'Book Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            ...books.entries.map((entry) {
              final moodName = entry.key.split('.').last;
              final data = entry.value as Map<String, dynamic>;
              final isSuccess = data['success'] == true;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: isSuccess ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          moodName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (isSuccess)
                          Text(
                            '${data['count']} books',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    if (isSuccess && data['sample_titles'] != null) ...[
                      const SizedBox(height: 4),
                      ...List.generate(
                        (data['sample_titles'] as List).length,
                        (index) {
                          final title = (data['sample_titles'] as List)[index];
                          final author = (data['sample_authors'] as List)[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 28, top: 2),
                            child: Text(
                              '• $title by $author',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (!isSuccess)
                      Padding(
                        padding: const EdgeInsets.only(left: 28, top: 4),
                        child: Text(
                          'Error: ${data['error']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
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
}

