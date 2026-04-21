// Translation of pcgen.gui2.dialog.KitSelectionDialog

import 'package:flutter/material.dart';

/// Dialog for selecting a kit to apply to a character.
class KitSelectionDialog extends StatefulWidget {
  final dynamic character; // CharacterFacade

  const KitSelectionDialog({super.key, required this.character});

  @override
  State<KitSelectionDialog> createState() => _KitSelectionDialogState();
}

class _KitSelectionDialogState extends State<KitSelectionDialog> {
  dynamic _selectedKit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Kit'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: ListView(
          children: const [
            ListTile(title: Text('No kits available')),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _selectedKit == null ? null : () => Navigator.pop(context),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
