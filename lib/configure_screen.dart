import 'package:flutter/material.dart';

import 'app_state.dart';
import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'storage_service.dart';
import 'stored_data_screen.dart';
import 'ui_helpers.dart';

/// "Configure" screen from the settings menu: app preferences grouped into
/// sections (Appearance, Account, Notifications, Data).
class ConfigureScreen extends StatefulWidget {
  const ConfigureScreen({super.key});

  @override
  State<ConfigureScreen> createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  bool _darkMode = darkModeNotifier.value;

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    darkModeNotifier.value = value; // updates the whole app right away
    await StorageService.setDarkMode(value); // remembered next time
    await StorageService.saveUserAction(
        value ? 'Turned on dark mode' : 'Turned off dark mode');
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start a new day?'),
        content: const Text(
            'All habits in "Done" will move back to "To Do".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await StorageService.resetProgress();
      showSuccessToast('Progress reset. Have a great day!');
    }
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        title: const Text('Configure'),
      ),
      body: ListView(
        children: [
          _sectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark mode'),
            subtitle: const Text('Easier on the eyes at night'),
            value: _darkMode,
            onChanged: _toggleDarkMode,
          ),
          _sectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Personal Info'),
            subtitle: const Text('Name, username, age, country, email, password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(const PersonalInfoScreen()),
          ),
          _sectionHeader('Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification preferences'),
            subtitle: const Text('Choose habits and reminder times'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(const NotificationsScreen()),
          ),
          _sectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('View stored data'),
            subtitle: const Text('See what is saved on this device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(const StoredDataScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Start a new day'),
            subtitle: const Text('Move all done habits back to To Do'),
            onTap: _resetProgress,
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('$appName v$appVersion',
                style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
