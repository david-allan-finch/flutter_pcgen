//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.AbilitiesInfoTab

import 'package:flutter/material.dart';
import 'models/character_combo_box_model.dart';
import 'package:flutter_pcgen/src/gui2/filter/filter_bar.dart';

/// Tab panel for viewing and selecting character abilities/feats.
class AbilitiesInfoTab extends StatefulWidget {
  const AbilitiesInfoTab({super.key});

  @override
  State<AbilitiesInfoTab> createState() => AbilitiesInfoTabState();
}

class AbilitiesInfoTabState extends State<AbilitiesInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) {
    setState(() => _character = character);
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return const Center(child: Text('No character loaded'));
    }
    return Column(
      children: [
        FilterBar(onFilterChanged: (_) {}),
        Expanded(
          child: Row(
            children: [
              // Available abilities panel
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Available',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView(
                        children: const [
                          ListTile(title: Text('Load a source to see abilities')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(),
              // Selected abilities panel
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Selected',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView(children: const []),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
