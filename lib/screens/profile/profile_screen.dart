import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'preferences_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUserModel;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            
            // Title
            Text(
              'Profile',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 48),

            // Profile info
            Text(
              user?.displayName ?? 'User',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),

            // Account section
            Text(
              'Account',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 16),
            _buildListItem(
              context,
              'Edit Profile',
              () {
                // TODO: Navigate to edit profile
              },
            ),
            const Divider(height: 1),
            _buildListItem(
              context,
              'My Preferences',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreferencesScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _buildListItem(
              context,
              'Blocked Apps',
              () {
                // TODO: Navigate to app blocking settings
              },
            ),

            const SizedBox(height: 48),

            // Preferences section
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 16),
            _buildListItem(
              context,
              'Notifications',
              () {
                // TODO: Navigate to notifications settings
              },
            ),
            const Divider(height: 1),
            _buildListItem(
              context,
              'Appearance',
              () {
                // TODO: Navigate to appearance settings
              },
            ),
            const Divider(height: 1),
            _buildListItem(
              context,
              'Language',
              () {
                // TODO: Navigate to language settings
              },
            ),

            const SizedBox(height: 48),

            // Support section
            Text(
              'Support',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 16),
            _buildListItem(
              context,
              'Help & Support',
              () {
                // TODO: Navigate to help
              },
            ),
            const Divider(height: 1),
            _buildListItem(
              context,
              'Privacy Policy',
              () {
                // TODO: Open privacy policy
              },
            ),
            const Divider(height: 1),
            _buildListItem(
              context,
              'Terms of Service',
              () {
                // TODO: Open terms
              },
            ),
            const Divider(height: 1),
            _buildListItem(
              context,
              'About',
              () {
                _showAboutDialog(context);
              },
            ),

            const SizedBox(height: 48),

            // Sign out button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final shouldSignOut = await showDialog<bool>(
                    context: context,
                    builder: (context) => Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sign out?',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Are you sure you want to sign out?',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Sign Out'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  if (shouldSignOut == true && context.mounted) {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }
                },
                child: const Text('Sign Out'),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(
              Icons.arrow_forward,
              size: 18,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About SOAR',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Version ${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
