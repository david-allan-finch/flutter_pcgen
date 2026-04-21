// Translation of pcgen.gui2.prefs.OutputPanel

import 'package:flutter/material.dart';

/// Preferences panel for output/export settings.
class OutputPanel extends StatefulWidget {
  const OutputPanel({super.key});

  @override
  State<OutputPanel> createState() => _OutputPanelState();
}

class _OutputPanelState extends State<OutputPanel> {
  bool _alwaysOpenExport = false;
  bool _saveWithPc = true;
  bool _cleanupTempFiles = true;
  String _defaultHtmlSheet = '';
  String _defaultPdfSheet = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Output', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        TextField(
          decoration: const InputDecoration(labelText: 'Default HTML Output Sheet'),
          onChanged: (v) => _defaultHtmlSheet = v,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: 'Default PDF Output Sheet'),
          onChanged: (v) => _defaultPdfSheet = v,
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Always open export file after export'),
          value: _alwaysOpenExport,
          onChanged: (v) => setState(() => _alwaysOpenExport = v ?? false),
        ),
        CheckboxListTile(
          title: const Text('Save output sheet with PC'),
          value: _saveWithPc,
          onChanged: (v) => setState(() => _saveWithPc = v ?? true),
        ),
        CheckboxListTile(
          title: const Text('Cleanup temp files on exit'),
          value: _cleanupTempFiles,
          onChanged: (v) => setState(() => _cleanupTempFiles = v ?? true),
        ),
      ],
    );
  }
}
