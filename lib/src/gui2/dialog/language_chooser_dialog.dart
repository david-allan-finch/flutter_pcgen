// Translation of pcgen.gui2.dialog.LanguageChooserDialog

import 'package:flutter/material.dart';

/// Dialog for choosing character languages.
class LanguageChooserDialog extends StatefulWidget {
  final dynamic character;

  const LanguageChooserDialog({super.key, required this.character});

  @override
  State<LanguageChooserDialog> createState() => _LanguageChooserDialogState();
}

class _LanguageChooserDialogState extends State<LanguageChooserDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Language'),
      content: const SizedBox(
        width: 400,
        height: 300,
        child: Center(child: Text('Language selection')),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    );
  }
}
