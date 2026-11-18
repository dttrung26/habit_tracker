import 'package:flutter/material.dart';

import 'habit_data.dart';
import 'storage_service.dart';
import 'ui_helpers.dart';

/// Detail screen for one habit. The habit data is passed in from the home
/// screen through navigation (Navigator.push).
class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String title = item['title'] as String;
    final String description = item['description'] as String? ?? '';
    final String category = item['category'] as String? ?? 'Custom';
    final bool isDone = item['isDone'] as bool? ?? false;
    final Color color = colorFromHex(item['color'] as String? ?? '#1E88E5');
    final List<String> related =
        List<String>.from(item['related'] as List? ?? const []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with icon, title and category
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: color,
                    child: Icon(iconForCategory(category),
                        size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(category),
                    avatar: Icon(Icons.label, size: 16, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isDone ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  isDone ? 'Status: Done today' : 'Status: To Do',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'About this habit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 16)),
            if (related.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Your other habits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: related
                    .map((habit) => Chip(
                          avatar: Icon(iconForCategory(categoryFor(habit)),
                              size: 16),
                          label: Text(habit),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(isDone ? Icons.undo : Icons.check),
                label: Text(isDone ? 'Move back to To Do' : 'Mark as Done'),
                onPressed: () async {
                  await StorageService.setHabitDone(title, !isDone);
                  showSuccessToast(
                      isDone ? 'Moved back to To Do' : 'Marked as done');
                  if (context.mounted) Navigator.pop(context, true);
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to List'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete habit'),
                onPressed: () => _confirmDelete(context, title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text('"$title" will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteHabit(title);
      showInfoToast('Habit deleted');
      if (context.mounted) Navigator.pop(context, true);
    }
  }
}
