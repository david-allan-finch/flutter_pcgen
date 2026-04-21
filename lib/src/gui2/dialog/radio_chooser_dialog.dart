// Translation of pcgen.gui2.dialog.RadioChooserDialog

import 'package:flutter/material.dart';
import '../../facade/core/chooser_facade.dart';

/// Dialog for making a single selection from a list (radio-button style).
class RadioChooserDialog extends StatefulWidget {
  final ChooserFacade chooser;

  const RadioChooserDialog({super.key, required this.chooser});

  static Future<void> showChooser(
      BuildContext context, ChooserFacade chooser) {
    return showDialog(
      context: context,
      builder: (_) => RadioChooserDialog(chooser: chooser),
    );
  }

  @override
  State<RadioChooserDialog> createState() => _RadioChooserDialogState();
}

class _RadioChooserDialogState extends State<RadioChooserDialog> {
  dynamic _selected;

  @override
  Widget build(BuildContext context) {
    final available = widget.chooser.getAvailableList();
    return AlertDialog(
      title: Text(widget.chooser.getName()),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ListView.builder(
          itemCount: available.getSize(),
          itemBuilder: (ctx, i) {
            final item = available.getElementAt(i);
            return RadioListTile(
              title: Text(item.toString()),
              value: item,
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v),
            );
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _selected == null
              ? null
              : () {
                  widget.chooser.commit();
                  Navigator.pop(context);
                },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
