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
// Translation of pcgen.gui2.equip.EquipCustomPanel

import 'package:flutter/material.dart';

/// Panel for customizing equipment items (adding/removing modifiers).
class EquipCustomPanel extends StatefulWidget {
  final dynamic equipment;
  final dynamic character;

  const EquipCustomPanel({
    super.key,
    required this.equipment,
    required this.character,
  });

  @override
  State<EquipCustomPanel> createState() => _EquipCustomPanelState();
}

class _EquipCustomPanelState extends State<EquipCustomPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Equipment Customization',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const Expanded(
          child: Center(child: Text('Modifier selection')),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('OK'),
            ),
          ],
        ),
      ],
    );
  }
}
