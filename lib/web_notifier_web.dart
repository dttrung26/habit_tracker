// Browser notifications for Flutter web (same approach as the course lab).
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Asks the browser for permission to show notifications.
Future<bool> requestWebNotificationPermission() async {
  if (!html.Notification.supported) return false;
  if (html.Notification.permission == 'granted') return true;
  final permission = await html.Notification.requestPermission();
  return permission == 'granted';
}

/// Shows a browser notification.
void showWebNotification(String title, String body) {
  html.Notification(title, body: body);
}
