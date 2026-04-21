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
// Translation of pcgen.gui2.dialog.SpellChoiceDialog

import 'package:flutter/material.dart';

/// Dialog for choosing spells.
class SpellChoiceDialog extends StatefulWidget {
  final dynamic spellBuilder; // SpellBuilderFacade

  const SpellChoiceDialog({super.key, required this.spellBuilder});

  @override
  State<SpellChoiceDialog> createState() => _SpellChoiceDialogState();
}

class _SpellChoiceDialogState extends State<SpellChoiceDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Spell'),
      content: const SizedBox(
        width: 500,
        height: 400,
        child: Center(child: Text('Spell selection')),
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
