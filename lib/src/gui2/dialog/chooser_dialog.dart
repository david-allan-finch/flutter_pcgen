//
// Copyright James Dempsey, 2012
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
// Translation of pcgen.gui2.dialog.ChooserDialog

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/facade/core/chooser_facade.dart';

/// Dialog for making selections from a list of available items.
class ChooserDialog extends StatefulWidget {
  final ChooserFacade chooser;

  const ChooserDialog({super.key, required this.chooser});

  static Future<void> showChooser(
      BuildContext context, ChooserFacade chooser) {
    return showDialog(
      context: context,
      builder: (_) => ChooserDialog(chooser: chooser),
    );
  }

  @override
  State<ChooserDialog> createState() => _ChooserDialogState();
}

class _ChooserDialogState extends State<ChooserDialog> {
  final List<dynamic> _selected = [];

  @override
  Widget build(BuildContext context) {
    final available = widget.chooser.getAvailableList();
    final selectedList = widget.chooser.getSelectedList();
    return AlertDialog(
      title: Text(widget.chooser.getName()),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: available.getSize(),
                      itemBuilder: (ctx, i) {
                        final item = available.getElementAt(i);
                        return ListTile(
                          title: Text(item.toString()),
                          onTap: () => setState(() => _selected.add(item)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedList.getSize(),
                      itemBuilder: (ctx, i) {
                        final item = selectedList.getElementAt(i);
                        return ListTile(title: Text(item.toString()));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.chooser.commit();
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
