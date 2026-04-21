//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
