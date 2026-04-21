//
// Copyright 2008 (C) James Dempsey
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
// Translation of pcgen.gui2.prefs.CharacterStatsPanel

import 'package:flutter/material.dart';

/// Preferences panel for character stat generation options.
class CharacterStatsPanel extends StatefulWidget {
  const CharacterStatsPanel({super.key});

  @override
  State<CharacterStatsPanel> createState() => _CharacterStatsPanelState();
}

class _CharacterStatsPanelState extends State<CharacterStatsPanel> {
  int _purchaseMethod = 0;
  int _rollMethod = 0;
  bool _allowNegativeMoney = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Character Stats', style: Theme.of(context).textTheme.titleMedium),
        const Divider(),
        DropdownButtonFormField<int>(
          value: _purchaseMethod,
          decoration: const InputDecoration(labelText: 'Purchase Method'),
          items: const [
            DropdownMenuItem(value: 0, child: Text('Standard')),
            DropdownMenuItem(value: 1, child: Text('Point Buy')),
          ],
          onChanged: (v) => setState(() => _purchaseMethod = v ?? 0),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _rollMethod,
          decoration: const InputDecoration(labelText: 'Roll Method'),
          items: const [
            DropdownMenuItem(value: 0, child: Text('4d6 drop lowest')),
            DropdownMenuItem(value: 1, child: Text('3d6')),
          ],
          onChanged: (v) => setState(() => _rollMethod = v ?? 0),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Allow Negative Money'),
          value: _allowNegativeMoney,
          onChanged: (v) => setState(() => _allowNegativeMoney = v ?? false),
        ),
      ],
    );
  }
}
