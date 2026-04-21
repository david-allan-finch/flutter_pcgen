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
// Translation of pcgen.gui2.tabs.EquipInfoTab

import 'package:flutter/material.dart';

/// Tab panel for the equipment/gear tab.
class EquipInfoTab extends StatefulWidget {
  const EquipInfoTab({super.key});

  @override
  State<EquipInfoTab> createState() => EquipInfoTabState();
}

class EquipInfoTabState extends State<EquipInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Available Equipment',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(child: ListView(children: const [])),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Equipped',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(child: ListView(children: const [])),
            ],
          ),
        ),
      ],
    );
  }
}
