import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/journal_service.dart';
import '../../services/mood_service.dart';
import '../../models/journal_entry.dart';
import 'write_journal_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalService>().loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalService = context.watch<JournalService>();
    final moodService = context.watch<MoodService>();

    final entries = _showFavoritesOnly
        ? journalService.favoriteEntries
        : journalService.searchEntries(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
            tooltip: _showFavoritesOnly ? 'Show all' : 'Show favorites',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search journal...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: journalService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? _buildEmptyState(context, journalService, moodService)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return _buildEntryCard(
                      context,
                      entries[index],
                      journalService,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newEntry(context, journalService, moodService),
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    JournalService journalService,
    MoodService moodService,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              _showFavoritesOnly
                  ? 'No favorite entries yet'
                  : _searchQuery.isNotEmpty
                      ? 'No entries found'
                      : 'Start Your Journaling Journey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _showFavoritesOnly
                  ? 'Mark entries as favorites to see them here'
                  : _searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Writing helps process emotions and track growth',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            if (!_showFavoritesOnly && _searchQuery.isEmpty) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _newEntry(context, journalService, moodService),
                icon: const Icon(Icons.edit),
                label: const Text('Write Your First Entry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(
    BuildContext context,
    JournalEntry entry,
    JournalService journalService,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewEntry(context, entry, journalService),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: entry.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      journalService.toggleFavorite(entry);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, y').format(entry.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (entry.moodType != null) ...[
                    const SizedBox(width: 16),
                    _getMoodIcon(entry.moodType!),
                  ],
                  if (entry.tags.isNotEmpty) ...[
                    const Spacer(),
                    Wrap(
                      spacing: 4,
                      children: entry.tags.take(2).map((tag) {
                        return Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(fontSize: 10),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMoodIcon(String moodType) {
    IconData icon;
    Color color;

    switch (moodType) {
      case 'veryHappy':
      case 'happy':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      case 'calm':
        icon = Icons.sentiment_satisfied;
        color = Colors.blue;
        break;
      case 'anxious':
      case 'stressed':
        icon = Icons.sentiment_neutral;
        color = Colors.orange;
        break;
      case 'sad':
      case 'verySad':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = Colors.grey;
    }

    return Icon(icon, size: 18, color: color);
  }

  void _newEntry(
    BuildContext context,
    JournalService journalService,
    MoodService moodService,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteJournalScreen(
          currentMood: moodService.todaysMood,
        ),
      ),
    );
  }

  void _viewEntry(
    BuildContext context,
    JournalEntry entry,
    JournalService journalService,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteJournalScreen(entry: entry),
      ),
    );
  }
}

