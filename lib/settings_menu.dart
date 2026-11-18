import 'package:flutter/material.dart';

import 'app_state.dart';
import 'configure_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'reports_screen.dart';
import 'storage_service.dart';
import 'ui_helpers.dart';

/// Settings menu: a side drawer opened from the hamburger icon (or the
/// settings icon) on the home screen.
class AppDrawer extends StatelessWidget {
  final String userName;

  /// Called after the user comes back from a screen opened in the menu,
  /// so the home screen can reload any changed data.
  final Future<void> Function()? onReturn;

  const AppDrawer({super.key, required this.userName, this.onReturn});

  Future<void> _openScreen(BuildContext context, Widget screen) async {
    final navigator = Navigator.of(context);
    navigator.pop(); // close the drawer first
    await navigator.push(MaterialPageRoute(builder: (context) => screen));
    if (onReturn != null) await onReturn!();
  }

  Future<void> _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    await StorageService.logout(); // clears the login session
    showInfoToast('You have signed out');
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showAbout(BuildContext context) {
    Navigator.of(context).pop(); // close the drawer
    showAboutDialog(
      context: context,
      applicationName: appName,
      applicationVersion: appVersion,
      applicationIcon: const AppLogo(size: 48),
      children: const [
        Text(
          'Habit Tracker helps you build positive habits. Track your daily '
          'habits, see your progress in reports and get reminders so you '
          'never miss a day.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: brandBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const AppLogo(size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hello, $userName!',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configure'),
            onTap: () => _openScreen(context, const ConfigureScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Personal Info'),
            onTap: () => _openScreen(context, const PersonalInfoScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => _openScreen(context, const ReportsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () => _openScreen(context, const NotificationsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () => _showAbout(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
