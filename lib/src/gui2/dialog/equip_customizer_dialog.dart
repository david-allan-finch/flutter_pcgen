// Translation of pcgen.gui2.dialog.EquipCustomizerDialog

import 'package:flutter/material.dart';

/// Dialog for customizing equipment (adding modifiers, etc.).
class EquipCustomizerDialog extends StatefulWidget {
  final dynamic equipment;
  final dynamic character;

  const EquipCustomizerDialog({
    super.key,
    required this.equipment,
    required this.character,
  });

  @override
  State<EquipCustomizerDialog> createState() => _EquipCustomizerDialogState();
}

class _EquipCustomizerDialogState extends State<EquipCustomizerDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customize Equipment'),
      content: const SizedBox(
        width: 600,
        height: 400,
        child: Center(child: Text('Equipment customization')),
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
