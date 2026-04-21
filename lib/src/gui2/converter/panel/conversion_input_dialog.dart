// Translation of pcgen.gui2.converter.panel.ConversionInputDialog

import 'package:flutter/material.dart';

/// Dialog that prompts for a text input during conversion (e.g., a new token value).
class ConversionInputDialog extends StatefulWidget {
  final String title;
  final String prompt;
  final String initialValue;

  const ConversionInputDialog({
    super.key,
    required this.title,
    required this.prompt,
    this.initialValue = '',
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String prompt,
    String initialValue = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => ConversionInputDialog(
        title: title,
        prompt: prompt,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<ConversionInputDialog> createState() => _ConversionInputDialogState();
}

class _ConversionInputDialogState extends State<ConversionInputDialog> {
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.prompt),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
