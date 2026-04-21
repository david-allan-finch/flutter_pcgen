// Translation of pcgen.gui2.dialog.SpellChoiceDialog

import 'package:flutter/material.dart';

/// Dialog for choosing spells.
class SpellChoiceDialog extends StatefulWidget {
  final dynamic spellBuilder; // SpellBuilderFacade

  const SpellChoiceDialog({super.key, required this.spellBuilder});

  @override
  State<SpellChoiceDialog> createState() => _SpellChoiceDialogState();
}

class _SpellChoiceDialogState extends State<SpellChoiceDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Spell'),
      content: const SizedBox(
        width: 500,
        height: 400,
        child: Center(child: Text('Spell selection')),
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
