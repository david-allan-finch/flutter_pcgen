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
// Translation of pcgen.gui3.preferences.DisplayOptionsPreferencesPanelController

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui3/preferences/display_options_preferences_panel_model.dart';

/// Controller/widget for the Display Options preferences panel.
class DisplayOptionsPreferencesPanelController extends StatelessWidget {
  final DisplayOptionsPreferencesPanelModel model;

  const DisplayOptionsPreferencesPanelController({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (ctx, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Show Tooltips'),
            value: model.showToolTips,
            onChanged: model.setShowToolTips,
          ),
          SwitchListTile(
            title: const Text('Show Memory Bar'),
            value: model.showMemoryBar,
            onChanged: model.setShowMemoryBar,
          ),
          SwitchListTile(
            title: const Text('Show Image Preview'),
            value: model.showImagePreview,
            onChanged: model.setShowImagePreview,
          ),
          ListTile(
            title: const Text('Font Size'),
            trailing: DropdownButton<int>(
              value: model.fontSize,
              items: [10, 11, 12, 13, 14, 16, 18]
                  .map((s) => DropdownMenuItem(value: s, child: Text('$s pt')))
                  .toList(),
              onChanged: (v) { if (v != null) model.setFontSize(v); },
            ),
          ),
          SwitchListTile(
            title: const Text('Collect Diagnostics'),
            value: model.collectDiagnostics,
            onChanged: model.setCollectDiagnostics,
          ),
        ],
      ),
    );
  }
}
