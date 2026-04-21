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
