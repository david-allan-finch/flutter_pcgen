// Translation of pcgen.gui3.preferences.InputPreferencesPanelController

import 'package:flutter/material.dart';
import 'input_preferences_model.dart';

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
