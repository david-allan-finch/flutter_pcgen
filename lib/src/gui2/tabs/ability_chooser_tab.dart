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
// Translation of pcgen.gui2.tabs.AbilityChooserTab

import 'package:flutter/material.dart';

/// Tab panel for choosing abilities from the available pool.
class AbilityChooserTab extends StatefulWidget {
  const AbilityChooserTab({super.key});

  @override
  State<AbilityChooserTab> createState() => AbilityChooserTabState();
}

class AbilityChooserTabState extends State<AbilityChooserTab> {
  dynamic _character;
  dynamic _category;

  void setCharacter(dynamic character) => setState(() => _character = character);
  void setCategory(dynamic category) => setState(() => _category = category);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_category != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Category: $_category',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Available'),
                    ),
                    Expanded(child: ListView(children: const [])),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_forward), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.arrow_back), onPressed: () {}),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Selected'),
                    ),
                    Expanded(child: ListView(children: const [])),
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
