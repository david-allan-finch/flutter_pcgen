// Translation of pcgen.gui2.doomsdaybook.NameButton

import 'package:flutter/material.dart';

/// A button that generates and displays a random name.
class NameButton extends StatefulWidget {
  final String label;
  final void Function(String name)? onGenerated;

  const NameButton({super.key, this.label = 'Name', this.onGenerated});

  @override
  State<NameButton> createState() => _NameButtonState();
}

class _NameButtonState extends State<NameButton> {
  String? _generatedName;

  void _generate() {
    // Simple placeholder — real implementation reads from DoomsdayBook xml data
    setState(() => _generatedName = 'Generated Name');
    widget.onGenerated?.call(_generatedName!);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _generate,
      child: Text(_generatedName ?? widget.label),
    );
  }
}
