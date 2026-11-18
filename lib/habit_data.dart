import 'package:flutter/material.dart';

/// Habits offered on the registration screen (from the course lab).
const List<String> availableHabits = [
  'Wake Up Early',
  'Workout',
  'Drink Water',
  'Meditate',
  'Read a Book',
  'Practice Gratitude',
  'Sleep 8 Hours',
  'Eat Healthy',
  'Journal',
  'Walk 10,000 Steps',
];

/// Colour (hex) for each built-in habit.
const Map<String, String> habitColors = {
  'Wake Up Early': '#FB8C00',
  'Workout': '#E53935',
  'Drink Water': '#673AB7',
  'Meditate': '#00897B',
  'Read a Book': '#D500F9',
  'Practice Gratitude': '#EC407A',
  'Sleep 8 Hours': '#3949AB',
  'Eat Healthy': '#43A047',
  'Journal': '#6D4C41',
  'Walk 10,000 Steps': '#1E88E5',
};

/// Category shown on habit cards and the detail screen.
const Map<String, String> habitCategories = {
  'Wake Up Early': 'Routine',
  'Workout': 'Fitness',
  'Drink Water': 'Health',
  'Meditate': 'Mindfulness',
  'Read a Book': 'Learning',
  'Practice Gratitude': 'Mindfulness',
  'Sleep 8 Hours': 'Health',
  'Eat Healthy': 'Nutrition',
  'Journal': 'Mindfulness',
  'Walk 10,000 Steps': 'Fitness',
};

/// Description shown on the detail screen for built-in habits.
const Map<String, String> defaultHabitDescriptions = {
  'Wake Up Early':
      'Start your day before 7 AM to give yourself quiet time to plan, exercise or simply enjoy a calm morning.',
  'Workout':
      'Move your body for at least 30 minutes. Any activity counts: gym, running, cycling, yoga or a home workout.',
  'Drink Water':
      'Aim for around 8 glasses of water a day. Staying hydrated improves focus, energy and mood.',
  'Meditate':
      'Spend 10 minutes in mindful breathing or guided meditation to reduce stress and clear your mind.',
  'Read a Book':
      'Read at least 20 pages a day. Small daily reading adds up to many books over a year.',
  'Practice Gratitude':
      'Write down three things you are grateful for. It builds a positive mindset over time.',
  'Sleep 8 Hours':
      'Keep a regular bedtime and get 7-8 hours of sleep so your body and mind can recover.',
  'Eat Healthy':
      'Include vegetables, fruit and protein in your meals and cut back on sugary snacks.',
  'Journal':
      'Spend a few minutes writing about your day, your goals and how you feel.',
  'Walk 10,000 Steps':
      'Take short walks during the day to reach 10,000 steps. Use the stairs whenever you can.',
};

/// Colours users can pick from when creating their own habit.
const List<String> customHabitPalette = [
  '#1E88E5',
  '#43A047',
  '#E53935',
  '#FB8C00',
  '#8E24AA',
  '#00897B',
  '#6D4C41',
  '#546E7A',
];

/// Converts a hex string such as "#1E88E5" into a Flutter [Color].
Color colorFromHex(String hexColor) {
  var value = hexColor.replaceAll('#', '');
  if (value.length == 6) {
    value = 'FF$value'; // add full opacity
  }
  return Color(int.tryParse(value, radix: 16) ?? 0xFF1E88E5);
}

/// Picks an icon that matches a habit category.
IconData iconForCategory(String category) {
  switch (category) {
    case 'Fitness':
      return Icons.fitness_center;
    case 'Health':
      return Icons.favorite;
    case 'Mindfulness':
      return Icons.self_improvement;
    case 'Learning':
      return Icons.menu_book;
    case 'Nutrition':
      return Icons.restaurant;
    case 'Routine':
      return Icons.wb_sunny;
    default:
      return Icons.star;
  }
}

String categoryFor(String habit) => habitCategories[habit] ?? 'Custom';
