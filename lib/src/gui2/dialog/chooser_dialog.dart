// Translation of pcgen.gui2.dialog.ChooserDialog

import 'package:flutter/material.dart';
import '../../facade/core/chooser_facade.dart';

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
