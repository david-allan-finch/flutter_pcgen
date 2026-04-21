// Translation of pcgen.gui2.dialog.PrintPreviewDialog

import 'package:flutter/material.dart';

/// Dialog for previewing and printing character sheets.
class PrintPreviewDialog extends StatefulWidget {
  final dynamic frame;

  const PrintPreviewDialog({super.key, this.frame});

  static void showPrintPreviewDialog(dynamic frame, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => PrintPreviewDialog(frame: frame),
    );
  }

  @override
  State<PrintPreviewDialog> createState() => _PrintPreviewDialogState();
}

class _PrintPreviewDialogState extends State<PrintPreviewDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Print Preview'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          children: [
            const Expanded(
              child: Center(child: Text('Character sheet preview')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Print'),
        ),
      ],
    );
  }
}
