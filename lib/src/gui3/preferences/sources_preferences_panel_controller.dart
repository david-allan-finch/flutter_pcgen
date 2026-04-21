// Translation of pcgen.gui3.preferences.SourcesPreferencesPanelController

import 'package:flutter/material.dart';

/// Controller/widget for the Sources preferences panel.
class SourcesPreferencesPanelController extends StatefulWidget {
  const SourcesPreferencesPanelController({super.key});

  @override
  State<SourcesPreferencesPanelController> createState() =>
      _SourcesPreferencesPanelControllerState();
}

class _SourcesPreferencesPanelControllerState
    extends State<SourcesPreferencesPanelController> {
  bool _loadLastSources = true;
  bool _allowMultipleSources = true;
  bool _saveSourcesWithChar = false;
  String _pccDirectory = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Load Last Sources on Startup'),
          value: _loadLastSources,
          onChanged: (v) => setState(() => _loadLastSources = v),
        ),
        SwitchListTile(
          title: const Text('Allow Multiple Source Types'),
          value: _allowMultipleSources,
          onChanged: (v) => setState(() => _allowMultipleSources = v),
        ),
        SwitchListTile(
          title: const Text('Save Sources with Character'),
          value: _saveSourcesWithChar,
          onChanged: (v) => setState(() => _saveSourcesWithChar = v),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('PCC Directory',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _pccDirectory),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => _pccDirectory = v,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // File picker would go here
                },
                child: const Text('Browse...'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
