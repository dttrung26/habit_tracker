import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Browser notifications on the web, nothing on mobile.
import 'web_notifier_stub.dart'
    if (dart.library.html) 'web_notifier_web.dart';

/// Notifications for the app.
///
/// * Android / iOS: local notifications with flutter_local_notifications.
/// * Web (Chrome): browser notifications, like the course lab.
///
/// Notifications are created on the device itself, so no server is needed.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const String _channelId = 'habit_reminders';
  static const String _channelName = 'Habit Reminders';
  static const String _channelDescription =
      'Reminders to work on your habits';

  /// Called once in main() before the app starts.
  static Future<void> init() async {
    // This package does not support the web, so skip it there.
    if (kIsWeb || _initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      debugPrint('Could not initialise notifications: $e');
    }
  }

  /// Asks the user for permission to show notifications.
  /// On Android 13 and newer this shows the system permission dialog.
  static Future<bool> requestPermission() async {
    if (kIsWeb) return requestWebNotificationPermission();
    await init();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Shows a notification straight away.
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      showWebNotification(title, body);
      return;
    }
    await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(0, title, body, details);
  }
}
