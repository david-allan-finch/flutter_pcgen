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
// Translation of pcgen.gui3.preferences.InputPreferencesPanelController

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui3/preferences/input_preferences_model.dart';

/// Controller/widget for the Input preferences panel.
class InputPreferencesPanelController extends StatelessWidget {
  final InputPreferencesModel model;

  const InputPreferencesPanelController({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (ctx, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Allow Negative HP'),
            value: model.allowNegativeHP,
            onChanged: model.setAllowNegativeHP,
          ),
          SwitchListTile(
            title: const Text('Allow Debt'),
            value: model.allowDebt,
            onChanged: model.setAllowDebt,
          ),
          SwitchListTile(
            title: const Text('Show Output Name Instead of Name'),
            value: model.showOutputNameInsteadOfName,
            onChanged: model.setShowOutputNameInsteadOfName,
          ),
          SwitchListTile(
            title: const Text('Use Highest Stat to Buy Down'),
            value: model.useHighestStatToBuyDown,
            onChanged: model.setUseHighestStatToBuyDown,
          ),
          ListTile(
            title: const Text('Max Level Increase per Session'),
            trailing: DropdownButton<int>(
              value: model.maxLevelIncrease,
              items: List.generate(10, (i) => i + 1)
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: (v) { if (v != null) model.setMaxLevelIncrease(v); },
            ),
          ),
        ],
      ),
    );
  }
}
