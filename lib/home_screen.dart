import 'package:flutter/material.dart';

import 'app_state.dart';
import 'detail_screen.dart';
import 'habit_data.dart';
import 'settings_menu.dart';
import 'storage_service.dart';
import 'ui_helpers.dart';

/// Home screen: greeting, "To Do" and "Done" habit lists, and a + button.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  String _displayName = '';
  Map<String, String> _todoHabits = {};
  Map<String, String> _completedHabits = {};
  Map<String, String> _descriptions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Reads the profile and habits from local storage.
  Future<void> _loadData() async {
    final profile = await StorageService.getUserProfile();
    final todo = await StorageService.getTodoHabits();
    final completed = await StorageService.getCompletedHabits();
    final descriptions = await StorageService.getHabitDescriptions();

    if (!mounted) return;
    setState(() {
      final name = (profile?['name'] as String? ?? '').trim();
      final username = (profile?['username'] as String? ?? '').trim();
      _displayName = name.isNotEmpty
          ? name
          : (username.isNotEmpty ? username : 'there');
      _todoHabits = todo;
      _completedHabits = completed;
      _descriptions = descriptions;
      _isLoading = false;
    });
  }

  /// Moves a habit between To Do and Done (UI first, then storage).
  Future<void> _setHabitDone(String name, bool done) async {
    setState(() {
      if (done) {
        final color = _todoHabits.remove(name);
        if (color != null) _completedHabits[name] = color;
      } else {
        final color = _completedHabits.remove(name);
        if (color != null) _todoHabits[name] = color;
      }
    });
    await StorageService.setHabitDone(name, done);
    if (done) showSuccessToast('Nice! "$name" marked as done');
  }

  Future<void> _openDetail(String name, String colorHex, bool isDone) async {
    final related = {..._todoHabits, ..._completedHabits}
        .keys
        .where((h) => h != name)
        .take(4)
        .toList();

    final item = <String, dynamic>{
      'title': name,
      'description': _descriptions[name] ??
          defaultHabitDescriptions[name] ??
          'A custom habit you created. Keep going!',
      'category': categoryFor(name),
      'color': colorHex,
      'isDone': isDone,
      'related': related,
    };

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(item: item)),
    );
    // Refresh in case the habit was changed on the detail screen.
    await _loadData();
  }

  Future<void> _showAddHabitDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedColor = customHabitPalette.first;

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('New Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration:
                          const InputDecoration(labelText: 'Habit name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          labelText: 'Description (optional)'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Colour'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: customHabitPalette.map((hex) {
                        final isSelected = hex == selectedColor;
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedColor = hex),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: colorFromHex(hex),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 18, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      showErrorToast('Please enter a habit name.');
                      return;
                    }
                    final error = await StorageService.addHabit(
                      name,
                      selectedColor,
                      descriptionController.text.trim(),
                    );
                    if (error != null) {
                      showErrorToast(error);
                      return;
                    }
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (added == true) {
      showSuccessToast('Habit added');
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(userName: _displayName, onReturn: _loadData),
      appBar: AppBar(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 34),
            const SizedBox(width: 10),
            Text(
              _isLoading ? 'Loading...' : appName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings menu',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Hello, $_displayName!',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${_completedHabits.length} of '
                    '${_todoHabits.length + _completedHabits.length} habits done today',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
                const SizedBox(height: 8),
                _buildSectionTitle('To Do 📝'),
                Expanded(
                  flex: 3,
                  child: _todoHabits.isEmpty
                      ? _buildEmptyMessage(
                          'Use the + button to create some habits!')
                      : _buildHabitList(_todoHabits, isDone: false),
                ),
                const Divider(height: 1),
                _buildSectionTitle('Done ✅🎉'),
                Expanded(
                  flex: 2,
                  child: _completedHabits.isEmpty
                      ? _buildEmptyMessage(
                          'Swipe right on an activity to mark as done.')
                      : _buildHabitList(_completedHabits, isDone: true),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        tooltip: 'Add habit',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor),
        ),
      ),
    );
  }

  Widget _buildHabitList(Map<String, String> habits, {required bool isDone}) {
    final entries = habits.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final name = entries[index].key;
        final colorHex = entries[index].value;
        return _buildHabitCard(name, colorHex, isDone);
      },
    );
  }

  Widget _buildHabitCard(String name, String colorHex, bool isDone) {
    final color = colorFromHex(colorHex);
    final category = categoryFor(name);

    return Dismissible(
      key: ValueKey('${isDone ? 'done' : 'todo'}_$name'),
      // Swipe right to mark as done, swipe left on a done habit to undo.
      direction:
          isDone ? DismissDirection.endToStart : DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isDone ? Colors.orange : Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: isDone ? Alignment.centerRight : Alignment.centerLeft,
        child: Icon(isDone ? Icons.undo : Icons.check, color: Colors.white),
      ),
      onDismissed: (_) => _setHabitDone(name, !isDone),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 1.5),
        ),
        child: ListTile(
          leading: Checkbox(
            value: isDone,
            activeColor: color,
            onChanged: (_) => _setHabitDone(name, !isDone),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(iconForCategory(category), size: 14, color: color),
              const SizedBox(width: 4),
              Text(category),
            ],
          ),
          // Navigation icon that opens the detail screen.
          trailing: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: color),
            tooltip: 'View details',
            onPressed: () => _openDetail(name, colorHex, isDone),
          ),
          onTap: () => _openDetail(name, colorHex, isDone),
        ),
      ),
    );
  }
}
