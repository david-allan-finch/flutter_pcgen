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
