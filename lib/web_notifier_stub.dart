// Used on Android/iOS, where browser notifications do not exist.
// The real web version is in web_notifier_web.dart.

Future<bool> requestWebNotificationPermission() async => false;

void showWebNotification(String title, String body) {}
