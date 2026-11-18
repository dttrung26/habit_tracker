import 'package:flutter/material.dart';

/// App-wide constants and shared state.
const String appName = 'Habit Tracker';
const String appVersion = '1.0.0';
const String logoPath = 'assets/images/logo.png';

/// Brand colour used in headers and buttons.
final Color brandBlue = Colors.blue.shade700;

/// Holds the dark mode setting so the whole app can react when it changes.
final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);
