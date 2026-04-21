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
