import 'package:flutter/material.dart';

import 'app_state.dart';
import 'habit_data.dart';
import 'storage_service.dart';

/// Reports screen: progress summary and recent activity, built from the data
/// saved in local storage.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  Map<String, String> _todo = {};
  Map<String, String> _done = {};
  List<String> _actions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final todo = await StorageService.getTodoHabits();
    final done = await StorageService.getCompletedHabits();
    final actions = await StorageService.getUserActions();
    if (!mounted) return;
    setState(() {
      _todo = todo;
      _done = done;
      _actions = actions.reversed.toList(); // newest first
      _loading = false;
    });
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _todo.length + _done.length;
    final rate = total == 0 ? 0.0 : _done.length / total;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        title: const Text('Reports'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      _statCard('Total habits', '$total', Icons.list_alt,
                          Colors.blue),
                      _statCard('Done today', '${_done.length}',
                          Icons.check_circle, Colors.green),
                      _statCard('Still to do', '${_todo.length}',
                          Icons.pending_actions, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Completion rate',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: rate,
                              minHeight: 14,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${(rate * 100).round()}% of your habits are done today'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Habits',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (total == 0)
                    const Text('No habits yet. Add some from the home screen.'),
                  ...{..._todo, ..._done}.entries.map((entry) {
                    final isDone = _done.containsKey(entry.key);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorFromHex(entry.value),
                          child: Icon(
                            iconForCategory(categoryFor(entry.key)),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(entry.key),
                        subtitle: Text(categoryFor(entry.key)),
                        trailing: Icon(
                          isDone ? Icons.check_circle : Icons.circle_outlined,
                          color: isDone ? Colors.green : Colors.grey,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text('Recent activity',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_actions.isEmpty) const Text('No activity yet.'),
                  ..._actions.take(15).map(
                        (action) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.history, size: 20),
                          title: Text(action),
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}
