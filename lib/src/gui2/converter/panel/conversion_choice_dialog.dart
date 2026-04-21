// Translation of pcgen.gui2.converter.panel.ConversionChoiceDialog

import 'package:flutter/material.dart';

/// Dialog that lets the user choose which conversion tokens to apply.
class ConversionChoiceDialog extends StatefulWidget {
  final String title;
  final List<String> choices;
  final String? initialChoice;

  const ConversionChoiceDialog({
    super.key,
    required this.title,
    required this.choices,
    this.initialChoice,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> choices,
    String? initialChoice,
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => ConversionChoiceDialog(
        title: title,
        choices: choices,
        initialChoice: initialChoice,
      ),
    );
  }

  @override
  State<ConversionChoiceDialog> createState() => _ConversionChoiceDialogState();
}

class _ConversionChoiceDialogState extends State<ConversionChoiceDialog> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialChoice ?? (widget.choices.isNotEmpty ? widget.choices.first : null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: ListView(
          shrinkWrap: true,
          children: widget.choices
              .map((c) => RadioListTile<String>(
                    value: c,
                    groupValue: _selected,
                    title: Text(c),
                    onChanged: (v) => setState(() => _selected = v),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selected != null
              ? () => Navigator.of(context).pop(_selected)
              : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
