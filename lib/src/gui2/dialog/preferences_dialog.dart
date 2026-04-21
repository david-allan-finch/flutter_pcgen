//
//
// Copyright 2001 (C) B. K. Oxley (binkley) <binkley@alumni.rice.edu>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation; either version 2.1 of
// the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.dialog.PreferencesDialog

import 'package:flutter/material.dart';

/// The PCGen preferences dialog.
class PreferencesDialog extends StatefulWidget {
  final String title;

  const PreferencesDialog({super.key, this.title = 'Preferences'});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const PreferencesDialog(),
    );
  }

  @override
  State<PreferencesDialog> createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<PreferencesDialog> {
  int _selectedPanel = 0;

  static const _panels = [
    'Display', 'Defaults', 'Input', 'Level Up', 'Hit Points',
    'Equipment', 'Sources', 'Colors', 'Copy Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 700,
        height: 500,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
              child: ListView.builder(
                itemCount: _panels.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(_panels[i], style: const TextStyle(fontSize: 13)),
                  selected: _selectedPanel == i,
                  onTap: () => setState(() => _selectedPanel = i),
                ),
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: Center(
                child: Text('${_panels[_selectedPanel]} preferences'),
              ),
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
          child: const Text('OK'),
        ),
      ],
    );
  }
}
