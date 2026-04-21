//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.dialog.CharacterHPDialog

import 'package:flutter/material.dart';

/// Dialog for viewing and editing character hit points.
class CharacterHPDialog extends StatefulWidget {
  final dynamic character; // CharacterFacade

  const CharacterHPDialog({super.key, required this.character});

  static Future<void> show(BuildContext context, dynamic character) {
    return showDialog(
      context: context,
      builder: (_) => CharacterHPDialog(character: character),
    );
  }

  @override
  State<CharacterHPDialog> createState() => _CharacterHPDialogState();
}

class _CharacterHPDialogState extends State<CharacterHPDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hit Points'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Character: ${widget.character?.getNameRef()?.get() ?? "Unknown"}'),
            const SizedBox(height: 16),
            // HP table would go here
            const Text('HP configuration per level'),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    );
  }
}
