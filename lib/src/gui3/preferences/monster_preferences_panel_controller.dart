//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
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
// Translation of pcgen.gui3.preferences.MonsterPreferencesPanelController

import 'package:flutter/material.dart';

/// Controller/widget for the Monster preferences panel.
class MonsterPreferencesPanelController extends StatefulWidget {
  const MonsterPreferencesPanelController({super.key});

  @override
  State<MonsterPreferencesPanelController> createState() =>
      _MonsterPreferencesPanelControllerState();
}

class _MonsterPreferencesPanelControllerState
    extends State<MonsterPreferencesPanelController> {
  bool _useMonsterDefault = true;
  int _monsterHpMethod = 0; // 0=Standard, 1=Max
  bool _showMonsterHD = true;

  static const List<String> _hpMethods = ['Standard (Roll)', 'Max'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Use Monster Default Settings'),
          value: _useMonsterDefault,
          onChanged: (v) => setState(() => _useMonsterDefault = v),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Monster HP Method',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ..._hpMethods.asMap().entries.map((e) => RadioListTile<int>(
              value: e.key,
              groupValue: _monsterHpMethod,
              title: Text(e.value),
              onChanged: (v) { if (v != null) setState(() => _monsterHpMethod = v); },
            )),
        const Divider(),
        SwitchListTile(
          title: const Text('Show Monster HD'),
          value: _showMonsterHD,
          onChanged: (v) => setState(() => _showMonsterHD = v),
        ),
      ],
    );
  }
}
