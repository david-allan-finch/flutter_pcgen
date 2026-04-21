// Translation of pcgen.gui3.preferences.DefaultsPreferencesPanelController

import 'package:flutter/material.dart';

/// Controller/widget for the Defaults preferences panel — house rules defaults.
class DefaultsPreferencesPanelController extends StatefulWidget {
  const DefaultsPreferencesPanelController({super.key});

  @override
  State<DefaultsPreferencesPanelController> createState() =>
      _DefaultsPreferencesPanelControllerState();
}

class _DefaultsPreferencesPanelControllerState
    extends State<DefaultsPreferencesPanelController> {
  bool _applyLoadPenaltyToACAndSkills = true;
  bool _applyLoadPenaltyToMovement = true;
  bool _useExperimentalCursor = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Apply Load Penalty to AC and Skills'),
          value: _applyLoadPenaltyToACAndSkills,
          onChanged: (v) => setState(() => _applyLoadPenaltyToACAndSkills = v),
        ),
        SwitchListTile(
          title: const Text('Apply Load Penalty to Movement'),
          value: _applyLoadPenaltyToMovement,
          onChanged: (v) => setState(() => _applyLoadPenaltyToMovement = v),
        ),
        SwitchListTile(
          title: const Text('Use Experimental Cursor'),
          value: _useExperimentalCursor,
          onChanged: (v) => setState(() => _useExperimentalCursor = v),
        ),
      ],
    );
  }
}
