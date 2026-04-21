// *
// RaceInfoTab.java Copyright James Dempsey, 2010
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.tabs.RaceInfoTab

import 'package:flutter/material.dart';

/// Tab panel for selecting and viewing race information.
class RaceInfoTab extends StatefulWidget {
  const RaceInfoTab({super.key});

  @override
  State<RaceInfoTab> createState() => RaceInfoTabState();
}

class RaceInfoTabState extends State<RaceInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Available Races',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(children: const [
                  ListTile(title: Text('Human')),
                  ListTile(title: Text('Elf')),
                  ListTile(title: Text('Dwarf')),
                  ListTile(title: Text('Halfling')),
                ]),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Race Info', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Expanded(child: Center(child: Text('Select a race to see info'))),
            ],
          ),
        ),
      ],
    );
  }
}
