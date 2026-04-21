// Translation of pcgen.gui2.prefs.LocationPanel

import 'package:flutter/material.dart';

/// Preferences panel for file location settings (data, output, backup dirs).
class LocationPanel extends StatefulWidget {
  const LocationPanel({super.key});

  @override
  State<LocationPanel> createState() => _LocationPanelState();
}

class _LocationPanelState extends State<LocationPanel> {
  final Map<String, TextEditingController> _controllers = {
    'Data Directory': TextEditingController(),
    'Output Directory': TextEditingController(),
    'Backup Directory': TextEditingController(),
    'Character Directory': TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('File Locations', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        ..._controllers.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(labelText: entry.key),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () {/* file picker */},
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
