import 'package:flutter/material.dart';

import 'app_state.dart';
import 'habit_data.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import 'ui_helpers.dart';

/// Notifications screen: turn notifications on or off, choose which habits
/// and times to be reminded about, and send a test notification.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const List<String> availableTimes = ['Morning', 'Afternoon', 'Evening'];

  bool notificationsEnabled = false;
  List<String> selectedHabits = [];
  List<String> selectedTimes = [];
  Map<String, String> allHabitsMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final enabled = await StorageService.getNotificationsEnabled();
    final habits = await StorageService.getAllHabits();
    final savedHabits = await StorageService.getNotificationHabits();
    final savedTimes = await StorageService.getNotificationTimes();

    if (!mounted) return;
    setState(() {
      notificationsEnabled = enabled;
      allHabitsMap = habits;
      // Ignore habits that have since been deleted.
      selectedHabits = savedHabits.where(habits.containsKey).toList();
      selectedTimes = savedTimes;
      _loading = false;
    });
  }

  Future<void> _saveNotificationSettings() async {
    await StorageService.saveNotificationSettings(
      enabled: notificationsEnabled,
      habits: selectedHabits,
      times: selectedTimes,
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Ask for permission when the user turns notifications on.
      final granted = await NotificationService.requestPermission();
      if (!granted) {
        showErrorToast(
            'Notification permission was denied. Allow notifications in your browser or phone settings.');
        return;
      }
    }
    if (!mounted) return;
    setState(() => notificationsEnabled = value);
    await _saveNotificationSettings();
    await StorageService.saveUserAction(
        value ? 'Turned on notifications' : 'Turned off notifications');
    showSuccessToast(
        value ? 'Notifications enabled' : 'Notifications disabled');
  }

  Future<void> _sendTestNotification() async {
    if (!notificationsEnabled) {
      showErrorToast('Turn on "Enable Notifications" first.');
      return;
    }

    final granted = await NotificationService.requestPermission();
    if (!granted) {
      showErrorToast(
          'Notification permission was denied. Allow notifications in your browser or phone settings.');
      return;
    }

    final habitsText =
        selectedHabits.isEmpty ? 'your habits' : selectedHabits.join(', ');
    await NotificationService.showNotification(
      title: 'Habit Reminder',
      body: "It's time to work on $habitsText!",
    );
    await StorageService.saveUserAction('Sent a test notification');
    showSuccessToast('Test notification sent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Notifications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications',
                        style: TextStyle(fontSize: 18)),
                    subtitle: const Text('Get reminders for your habits'),
                    value: notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Select Habits for Notification',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (allHabitsMap.isEmpty)
                    const Text('Add some habits on the home screen first.'),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: allHabitsMap.entries.map((entry) {
                      final habit = entry.key;
                      final color = colorFromHex(entry.value);
                      return FilterChip(
                        label: Text(habit),
                        labelStyle: TextStyle(color: color),
                        selected: selectedHabits.contains(habit),
                        selectedColor: color.withAlpha(77),
                        checkmarkColor: color,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: color, width: 2.0),
                        onSelected: notificationsEnabled
                            ? (bool selected) {
                                setState(() {
                                  if (selected) {
                                    selectedHabits.add(habit);
                                  } else {
                                    selectedHabits.remove(habit);
                                  }
                                });
                                _saveNotificationSettings();
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Times for Notification',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: availableTimes.map((time) {
                      return FilterChip(
                        label: Text(time),
                        avatar: Icon(
                          time == 'Morning'
                              ? Icons.wb_sunny
                              : time == 'Afternoon'
                                  ? Icons.wb_cloudy
                                  : Icons.nights_stay,
                          size: 18,
                        ),
                        selected: selectedTimes.contains(time),
                        onSelected: notificationsEnabled
                            ? (bool selected) {
                                setState(() {
                                  if (selected) {
                                    selectedTimes.add(time);
                                  } else {
                                    selectedTimes.remove(time);
                                  }
                                });
                                _saveNotificationSettings();
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                  if (!notificationsEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Turn on notifications to choose habits and times.',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _sendTestNotification,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Send Test Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
