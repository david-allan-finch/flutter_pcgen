// Translation of pcgen.gui3.dialog.RememberingChoiceDialog

import 'package:flutter/material.dart';

/// A choice dialog that can remember the user's choice so it doesn't ask again.
class RememberingChoiceDialog extends StatefulWidget {
  final String title;
  final String message;
  final List<String> choices;
  final bool showRememberCheck;

  const RememberingChoiceDialog({
    super.key,
    required this.title,
    required this.message,
    required this.choices,
    this.showRememberCheck = true,
  });

  static Future<({String choice, bool remember})?> show(
    BuildContext context, {
    required String title,
    required String message,
    required List<String> choices,
    bool showRememberCheck = true,
  }) {
    return showDialog<({String choice, bool remember})>(
      context: context,
      builder: (ctx) => RememberingChoiceDialog(
        title: title,
        message: message,
        choices: choices,
        showRememberCheck: showRememberCheck,
      ),
    );
  }

  @override
  State<RememberingChoiceDialog> createState() => _RememberingChoiceDialogState();
}

class _RememberingChoiceDialogState extends State<RememberingChoiceDialog> {
  String? _selected;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.choices.isNotEmpty ? widget.choices.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: 12),
          ...widget.choices.map((c) => RadioListTile<String>(
                value: c,
                groupValue: _selected,
                title: Text(c),
                onChanged: (v) => setState(() => _selected = v),
              )),
          if (widget.showRememberCheck) ...[
            const Divider(),
            CheckboxListTile(
              value: _remember,
              onChanged: (v) => setState(() => _remember = v ?? false),
              title: const Text("Don't ask again"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context)
                  .pop((choice: _selected!, remember: _remember)),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
