//
// Copyright 2009 (C) James Dempsey
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
// Translation of pcgen.gui2.prefs.HouseRulesPanel

import 'package:flutter/material.dart';

/// Preferences panel for house rules (XP for encounter, etc.).
class HouseRulesPanel extends StatefulWidget {
  const HouseRulesPanel({super.key});

  @override
  State<HouseRulesPanel> createState() => _HouseRulesPanelState();
}

class _HouseRulesPanelState extends State<HouseRulesPanel> {
  bool _freeClothes = true;
  bool _freeLanguage = true;
  bool _crossClassSkillCap = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('House Rules', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        CheckboxListTile(
          title: const Text('Free Clothes at start'),
          value: _freeClothes,
          onChanged: (v) => setState(() => _freeClothes = v ?? true),
        ),
        CheckboxListTile(
          title: const Text('Free language at start'),
          value: _freeLanguage,
          onChanged: (v) => setState(() => _freeLanguage = v ?? true),
        ),
        CheckboxListTile(
          title: const Text('Cross class skill max = rank cap'),
          value: _crossClassSkillCap,
          onChanged: (v) => setState(() => _crossClassSkillCap = v ?? true),
        ),
      ],
    );
  }
}
