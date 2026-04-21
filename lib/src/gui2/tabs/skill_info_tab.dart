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
// Translation of pcgen.gui2.tabs.SkillInfoTab

import 'package:flutter/material.dart';

/// Tab panel for viewing and assigning skill ranks.
class SkillInfoTab extends StatefulWidget {
  const SkillInfoTab({super.key});

  @override
  State<SkillInfoTab> createState() => SkillInfoTabState();
}

class SkillInfoTabState extends State<SkillInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Text('Skill Points Remaining: '),
              Text('${_getRemainingPoints()}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Skill')),
                DataColumn(label: Text('Ranks')),
                DataColumn(label: Text('Modifier')),
                DataColumn(label: Text('Total')),
              ],
              rows: const [],
            ),
          ),
        ),
      ],
    );
  }

  int _getRemainingPoints() {
    try { return _character?.getSkillPool() as int? ?? 0; }
    catch (_) { return 0; }
  }
}
