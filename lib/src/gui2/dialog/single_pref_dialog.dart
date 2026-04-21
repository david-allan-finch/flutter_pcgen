// Translation of pcgen.gui2.dialog.SinglePrefDialog

import 'package:flutter/material.dart';

/// A simple dialog for editing a single preference value.
class SinglePrefDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final void Function(String value)? onSave;

  const SinglePrefDialog({
    super.key,
    required this.title,
    required this.label,
    this.initialValue = '',
    this.onSave,
  });

  @override
  State<SinglePrefDialog> createState() => _SinglePrefDialogState();
}

class _SinglePrefDialogState extends State<SinglePrefDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.label),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            widget.onSave?.call(_controller.text);
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
