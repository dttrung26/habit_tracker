import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/habit_data.dart';
import 'package:habit_tracker/ui_helpers.dart';

void main() {
  test('colorFromHex converts hex strings to colours', () {
    expect(colorFromHex('#1E88E5'), const Color(0xFF1E88E5));
    expect(colorFromHex('43A047'), const Color(0xFF43A047));
  });

  test('isValidEmail accepts good emails and rejects bad ones', () {
    expect(isValidEmail('wilson@example.com'), isTrue);
    expect(isValidEmail('not-an-email'), isFalse);
    expect(isValidEmail(''), isFalse);
  });

  test('every built-in habit has a colour, category and description', () {
    for (final habit in availableHabits) {
      expect(habitColors.containsKey(habit), isTrue, reason: habit);
      expect(habitCategories.containsKey(habit), isTrue, reason: habit);
      expect(defaultHabitDescriptions.containsKey(habit), isTrue,
          reason: habit);
    }
  });
}
