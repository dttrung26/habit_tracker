import 'package:flutter/material.dart';

import 'app_state.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'notification_service.dart';
import 'storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up local notifications (Android) before the app starts.
  await NotificationService.init();

  // Restore saved preferences and login state from local storage.
  darkModeNotifier.value = await StorageService.getDarkMode();
  final bool isLoggedIn = await StorageService.isLoggedIn();

  runApp(HabitTrackerApp(isLoggedIn: isLoggedIn));
}

class HabitTrackerApp extends StatelessWidget {
  final bool isLoggedIn;

  const HabitTrackerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // Logged-in users go straight to Home (login state persists).
          home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
        );
      },
    );
  }
}
