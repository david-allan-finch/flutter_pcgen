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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui3.preferences.LevelUpPreferencesPanelController

import 'package:flutter/material.dart';
import 'level_up_preferences_model.dart';

/// Controller/widget for the Level Up preferences panel.
class LevelUpPreferencesPanelController extends StatelessWidget {
  final LevelUpPreferencesModel model;

  const LevelUpPreferencesPanelController({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (ctx, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('HP Roll Method'),
            trailing: DropdownButton<String>(
              value: model.hpRollMethod,
              items: LevelUpPreferencesModel.hpRollMethods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) { if (v != null) model.setHpRollMethod(v); },
            ),
          ),
          if (model.hpRollMethod == 'Percentage')
            ListTile(
              title: const Text('HP Percentage'),
              trailing: SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: model.hpPercentage.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) model.setHpPercentage(n);
                  },
                  decoration: const InputDecoration(
                    suffixText: '%',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ),
          SwitchListTile(
            title: const Text('Ask for HP Method on Level Up'),
            value: model.askForHPMethod,
            onChanged: model.setAskForHPMethod,
          ),
          SwitchListTile(
            title: const Text('Show Info Panel on Level Up'),
            value: model.showInfoOnLevelUp,
            onChanged: model.setShowInfoOnLevelUp,
          ),
        ],
      ),
    );
  }
}
