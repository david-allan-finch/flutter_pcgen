// Translation of pcgen.gui3.preferences.DisplayOptionsPreferencesPanelController

import 'package:flutter/material.dart';
import 'display_options_preferences_panel_model.dart';

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
