import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),

            // Profile sections
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Account',
              [
                _buildListTile(
                  context,
                  Icons.edit,
                  'Edit Profile',
                  () {
                    // TODO: Navigate to edit profile
                  },
                ),
                _buildListTile(
                  context,
                  Icons.access_time,
                  'Mood Check-in Time',
                  () {
                    // TODO: Navigate to set reminder time
                  },
                ),
                _buildListTile(
                  context,
                  Icons.block,
                  'Blocked Apps',
                  () {
                    // TODO: Navigate to app blocking settings
                  },
                ),
              ],
            ),
            const Divider(height: 32),
            _buildSection(
              context,
              'Preferences',
              [
                _buildListTile(
                  context,
                  Icons.notifications,
                  'Notifications',
                  () {
                    // TODO: Navigate to notifications settings
                  },
                ),
                _buildListTile(
                  context,
                  Icons.palette,
                  'Appearance',
                  () {
                    // TODO: Navigate to appearance settings
                  },
                ),
                _buildListTile(
                  context,
                  Icons.language,
                  'Language',
                  () {
                    // TODO: Navigate to language settings
                  },
                ),
              ],
            ),
            const Divider(height: 32),
            _buildSection(
              context,
              'Support',
              [
                _buildListTile(
                  context,
                  Icons.help,
                  'Help & Support',
                  () {
                    // TODO: Navigate to help
                  },
                ),
                _buildListTile(
                  context,
                  Icons.privacy_tip,
                  'Privacy Policy',
                  () {
                    // TODO: Open privacy policy
                  },
                ),
                _buildListTile(
                  context,
                  Icons.description,
                  'Terms of Service',
                  () {
                    // TODO: Open terms
                  },
                ),
                _buildListTile(
                  context,
                  Icons.info,
                  'About',
                  () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
            const Divider(height: 32),

            // Sign out button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (shouldSignOut == true && context.mounted) {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About SOAR'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appTagline,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Text('Version: ${AppConstants.appVersion}'),
              const SizedBox(height: 8),
              const Text(
                'SOAR is your personal wellness companion, helping you track your mood, '
                'stay focused, and connect with supportive communities.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

