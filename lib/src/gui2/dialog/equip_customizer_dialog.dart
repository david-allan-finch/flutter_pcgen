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
// Translation of pcgen.gui2.dialog.EquipCustomizerDialog

import 'package:flutter/material.dart';

/// Dialog for customizing equipment (adding modifiers, etc.).
class EquipCustomizerDialog extends StatefulWidget {
  final dynamic equipment;
  final dynamic character;

  const EquipCustomizerDialog({
    super.key,
    required this.equipment,
    required this.character,
  });

  @override
  State<EquipCustomizerDialog> createState() => _EquipCustomizerDialogState();
}

class _EquipCustomizerDialogState extends State<EquipCustomizerDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customize Equipment'),
      content: const SizedBox(
        width: 600,
        height: 400,
        child: Center(child: Text('Equipment customization')),
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
