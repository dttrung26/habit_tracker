import 'dart:convert';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'storage_service.dart';

/// Shows every key/value saved in local storage (SharedPreferences).
/// Useful for checking that data really persists on the device.
class StoredDataScreen extends StatefulWidget {
  const StoredDataScreen({super.key});

  @override
  State<StoredDataScreen> createState() => _StoredDataScreenState();
}

class _StoredDataScreenState extends State<StoredDataScreen> {
  Map<String, Object?> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StorageService.getAllStoredData();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  /// Formats a stored value for display. The password is hidden.
  String _formatValue(String key, Object? value) {
    if (value == null) return 'null';
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map || decoded is List) {
          if (key == StorageService.keyUserProfile && decoded is Map) {
            decoded['password'] = '******';
          }
          return const JsonEncoder.withIndent('  ').convert(decoded);
        }
      } catch (_) {
        // Not JSON, show as plain text.
      }
      return value;
    }
    if (value is List) return value.join('\n');
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        title: const Text('Local Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Data saved on this device with SharedPreferences. '
                      'It is still here after you close and reopen the app.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_data.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Nothing saved yet.')),
                  ),
                ..._data.entries.map(
                  (entry) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            _formatValue(entry.key, entry.value),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
