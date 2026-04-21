//
// CompanionInfoTab.java Copyright 2012 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms of the
// GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1
// of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with this library;
// if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
// 02111-1307 USA
//
// Translation of pcgen.gui2.tabs.CompanionInfoTab

import 'package:flutter/material.dart';

/// Tab panel for managing character companions (animal companion, familiar, etc.).
class CompanionInfoTab extends StatefulWidget {
  const CompanionInfoTab({super.key});

  @override
  State<CompanionInfoTab> createState() => CompanionInfoTabState();
}

class CompanionInfoTabState extends State<CompanionInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Companions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Expanded(
          child: ListView(
            children: const [
              ListTile(title: Text('No companions')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Companion'),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
