//
// Copyright James Dempsey, 2013
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
// Translation of pcgen.gui2.dialog.RadioChooserDialog

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/facade/core/chooser_facade.dart';

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
