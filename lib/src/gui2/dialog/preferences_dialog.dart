// Translation of pcgen.gui2.dialog.PreferencesDialog

import 'package:flutter/material.dart';

/// The PCGen preferences dialog.
class PreferencesDialog extends StatefulWidget {
  final String title;

  const PreferencesDialog({super.key, this.title = 'Preferences'});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const PreferencesDialog(),
    );
  }

  @override
  State<PreferencesDialog> createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<PreferencesDialog> {
  int _selectedPanel = 0;

  static const _panels = [
    'Display', 'Defaults', 'Input', 'Level Up', 'Hit Points',
    'Equipment', 'Sources', 'Colors', 'Copy Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 700,
        height: 500,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
              child: ListView.builder(
                itemCount: _panels.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(_panels[i], style: const TextStyle(fontSize: 13)),
                  selected: _selectedPanel == i,
                  onTap: () => setState(() => _selectedPanel = i),
                ),
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: Center(
                child: Text('${_panels[_selectedPanel]} preferences'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
