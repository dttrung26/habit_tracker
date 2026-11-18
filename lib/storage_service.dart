import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'habit_data.dart';

/// Local storage (persistence) for the whole app.
///
/// Everything is saved on the device with SharedPreferences, so the data is
/// still there after the app is closed and opened again:
///   * the registered user profile and the login state
///   * the user's habits (To Do and Done) and their descriptions
///   * a log of user actions (shown on the Reports screen)
///   * settings such as dark mode and notification preferences
class StorageService {
  // Keys used in local storage
  static const String keyUserProfile = 'userProfile';
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyTodoHabits = 'selectedHabitsMap';
  static const String keyCompletedHabits = 'completedHabitsMap';
  static const String keyHabitDescriptions = 'habitDescriptions';
  static const String keyUserActions = 'userActions';
  static const String keyDarkMode = 'darkMode';
  static const String keyNotificationsEnabled = 'notificationsEnabled';
  static const String keyNotificationHabits = 'notificationHabits';
  static const String keyNotificationTimes = 'notificationTimes';

  static const int _maxActions = 50;

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  // ---------------------------------------------------------------------------
  // User profile
  // ---------------------------------------------------------------------------

  /// Saves the user profile as JSON.
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final prefs = await _prefs();
    await prefs.setString(keyUserProfile, jsonEncode(profile));
  }

  /// Reads the saved user profile, or null if nobody has registered yet.
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await _prefs();
    final profileString = prefs.getString(keyUserProfile);
    if (profileString == null) return null;
    return Map<String, dynamic>.from(jsonDecode(profileString) as Map);
  }

  /// Registers a new account on this device.
  /// Returns an error message, or null when registration succeeds.
  static Future<String?> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required int age,
    required String country,
    required List<String> habits,
  }) async {
    final existing = await getUserProfile();
    final existingEmail = (existing?['email'] as String?)?.toLowerCase();
    if (existingEmail != null && existingEmail == email.toLowerCase()) {
      return 'An account with this email already exists. Please log in instead.';
    }

    await saveUserProfile({
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'age': age,
      'country': country,
    });

    // Start with fresh habit data for the new account.
    final Map<String, String> todo = {
      for (final habit in habits)
        habit: habitColors[habit] ?? customHabitPalette.first,
    };
    await saveTodoHabits(todo);
    await saveCompletedHabits({});

    final prefs = await _prefs();
    await prefs.remove(keyHabitDescriptions);
    await prefs.remove(keyUserActions);
    await prefs.remove(keyNotificationHabits);
    await setLoggedIn(false);

    await saveUserAction('Registered a new account');
    return null;
  }

  /// Checks the email and password against the saved account.
  static Future<bool> login(String email, String password) async {
    final profile = await getUserProfile();
    if (profile == null) return false;

    final savedEmail = (profile['email'] as String? ?? '').toLowerCase();
    final savedPassword = profile['password'] as String? ?? '';
    final success =
        savedEmail == email.toLowerCase() && savedPassword == password;

    if (success) {
      await setLoggedIn(true);
      await saveUserAction('Logged in');
    }
    return success;
  }

  /// Ends the session. The account and habits stay saved so the user can
  /// log in again.
  static Future<void> logout() async {
    await saveUserAction('Signed out');
    await setLoggedIn(false);
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(keyIsLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // ---------------------------------------------------------------------------
  // Habits
  // ---------------------------------------------------------------------------

  static Map<String, String> _decodeStringMap(String? value) {
    if (value == null || value.isEmpty) return {};
    return Map<String, String>.from(jsonDecode(value) as Map);
  }

  /// Habits still to do: habit name -> colour hex.
  static Future<Map<String, String>> getTodoHabits() async {
    final prefs = await _prefs();
    return _decodeStringMap(prefs.getString(keyTodoHabits));
  }

  static Future<void> saveTodoHabits(Map<String, String> habits) async {
    final prefs = await _prefs();
    await prefs.setString(keyTodoHabits, jsonEncode(habits));
  }

  /// Habits marked as done: habit name -> colour hex.
  static Future<Map<String, String>> getCompletedHabits() async {
    final prefs = await _prefs();
    return _decodeStringMap(prefs.getString(keyCompletedHabits));
  }

  static Future<void> saveCompletedHabits(Map<String, String> habits) async {
    final prefs = await _prefs();
    await prefs.setString(keyCompletedHabits, jsonEncode(habits));
  }

  /// All habits (To Do and Done together).
  static Future<Map<String, String>> getAllHabits() async {
    final todo = await getTodoHabits();
    final completed = await getCompletedHabits();
    return {...todo, ...completed};
  }

  /// Moves a habit between To Do and Done.
  static Future<void> setHabitDone(String name, bool done) async {
    final todo = await getTodoHabits();
    final completed = await getCompletedHabits();

    if (done) {
      final color = todo.remove(name) ?? completed[name] ?? customHabitPalette.first;
      completed[name] = color;
    } else {
      final color = completed.remove(name) ?? todo[name] ?? customHabitPalette.first;
      todo[name] = color;
    }

    await saveTodoHabits(todo);
    await saveCompletedHabits(completed);
    await saveUserAction(
        done ? 'Completed "$name"' : 'Moved "$name" back to To Do');
  }

  /// Adds a new habit. Returns an error message, or null on success.
  static Future<String?> addHabit(
      String name, String colorHex, String description) async {
    final all = await getAllHabits();
    final exists = all.keys.any((h) => h.toLowerCase() == name.toLowerCase());
    if (exists) return 'You already have a habit called "$name".';

    final todo = await getTodoHabits();
    todo[name] = colorHex;
    await saveTodoHabits(todo);
    if (description.isNotEmpty) {
      await saveHabitDescription(name, description);
    }
    await saveUserAction('Added habit "$name"');
    return null;
  }

  /// Deletes a habit everywhere it is stored.
  static Future<void> deleteHabit(String name) async {
    final todo = await getTodoHabits();
    final completed = await getCompletedHabits();
    todo.remove(name);
    completed.remove(name);
    await saveTodoHabits(todo);
    await saveCompletedHabits(completed);

    final descriptions = await getHabitDescriptions();
    if (descriptions.remove(name) != null) {
      final prefs = await _prefs();
      await prefs.setString(keyHabitDescriptions, jsonEncode(descriptions));
    }

    final notificationHabits = await getNotificationHabits();
    if (notificationHabits.remove(name)) {
      final prefs = await _prefs();
      await prefs.setStringList(keyNotificationHabits, notificationHabits);
    }

    await saveUserAction('Deleted habit "$name"');
  }

  /// Moves every completed habit back to To Do (start a new day).
  static Future<void> resetProgress() async {
    final todo = await getTodoHabits();
    final completed = await getCompletedHabits();
    todo.addAll(completed);
    await saveTodoHabits(todo);
    await saveCompletedHabits({});
    await saveUserAction('Reset progress for a new day');
  }

  /// Custom descriptions: habit name -> description.
  static Future<Map<String, String>> getHabitDescriptions() async {
    final prefs = await _prefs();
    return _decodeStringMap(prefs.getString(keyHabitDescriptions));
  }

  static Future<void> saveHabitDescription(
      String name, String description) async {
    final descriptions = await getHabitDescriptions();
    descriptions[name] = description;
    final prefs = await _prefs();
    await prefs.setString(keyHabitDescriptions, jsonEncode(descriptions));
  }

  // ---------------------------------------------------------------------------
  // User actions (activity log)
  // ---------------------------------------------------------------------------

  static Future<void> saveUserAction(String action) async {
    final prefs = await _prefs();
    final actions =
        List<String>.from(prefs.getStringList(keyUserActions) ?? <String>[]);
    actions.add('${_timestamp()} - $action');
    if (actions.length > _maxActions) {
      actions.removeRange(0, actions.length - _maxActions);
    }
    await prefs.setStringList(keyUserActions, actions);
  }

  static Future<List<String>> getUserActions() async {
    final prefs = await _prefs();
    return List<String>.from(prefs.getStringList(keyUserActions) ?? <String>[]);
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  static Future<bool> getDarkMode() async {
    final prefs = await _prefs();
    return prefs.getBool(keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(keyDarkMode, value);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs();
    return prefs.getBool(keyNotificationsEnabled) ?? false;
  }

  static Future<List<String>> getNotificationHabits() async {
    final prefs = await _prefs();
    return List<String>.from(
        prefs.getStringList(keyNotificationHabits) ?? <String>[]);
  }

  static Future<List<String>> getNotificationTimes() async {
    final prefs = await _prefs();
    return List<String>.from(
        prefs.getStringList(keyNotificationTimes) ?? <String>[]);
  }

  static Future<void> saveNotificationSettings({
    required bool enabled,
    required List<String> habits,
    required List<String> times,
  }) async {
    final prefs = await _prefs();
    await prefs.setBool(keyNotificationsEnabled, enabled);
    await prefs.setStringList(keyNotificationHabits, habits);
    await prefs.setStringList(keyNotificationTimes, times);
  }

  // ---------------------------------------------------------------------------
  // Debug view of everything in local storage
  // ---------------------------------------------------------------------------

  /// Returns every key and value currently saved in local storage.
  static Future<Map<String, Object?>> getAllStoredData() async {
    final prefs = await _prefs();
    await prefs.reload();
    final keys = prefs.getKeys().toList()..sort();
    return {for (final key in keys) key: prefs.get(key)};
  }

  static String _timestamp() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}';
  }
}
