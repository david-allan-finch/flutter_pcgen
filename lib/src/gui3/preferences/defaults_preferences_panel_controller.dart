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
