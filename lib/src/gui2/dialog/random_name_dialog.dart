// Translation of pcgen.gui2.dialog.RandomNameDialog

import 'package:flutter/material.dart';

/// Dialog for generating a random name for a character.
class RandomNameDialog extends StatefulWidget {
  final dynamic character;

  const RandomNameDialog({super.key, required this.character});

  @override
  State<RandomNameDialog> createState() => _RandomNameDialogState();
}

class _RandomNameDialogState extends State<RandomNameDialog> {
  String _generatedName = '';

  void _generateName() {
    setState(() => _generatedName = 'Random Name ${DateTime.now().millisecond}');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Random Name Generator'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_generatedName.isEmpty ? 'Press Generate' : _generatedName,
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _generateName, child: const Text('Generate')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _generatedName.isEmpty
              ? null
              : () => Navigator.pop(context, _generatedName),
          child: const Text('Use Name'),
        ),
      ],
    );
  }
}
