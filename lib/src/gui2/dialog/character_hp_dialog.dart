// Translation of pcgen.gui2.dialog.CharacterHPDialog

import 'package:flutter/material.dart';

/// Dialog for viewing and editing character hit points.
class CharacterHPDialog extends StatefulWidget {
  final dynamic character; // CharacterFacade

  const CharacterHPDialog({super.key, required this.character});

  static Future<void> show(BuildContext context, dynamic character) {
    return showDialog(
      context: context,
      builder: (_) => CharacterHPDialog(character: character),
    );
  }

  @override
  State<CharacterHPDialog> createState() => _CharacterHPDialogState();
}

class _CharacterHPDialogState extends State<CharacterHPDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hit Points'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Character: ${widget.character?.getNameRef()?.get() ?? "Unknown"}'),
            const SizedBox(height: 16),
            // HP table would go here
            const Text('HP configuration per level'),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    );
  }
}
