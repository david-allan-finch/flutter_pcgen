// Translation of pcgen.gui2.converter.panel.GameModePanel

import 'package:flutter/material.dart';
import 'convert_sub_panel.dart';

/// Wizard step: select which game mode to convert data for.
class GameModePanel extends ConvertSubPanel {
  final List<String> gameModes;

  const GameModePanel({super.key, required this.gameModes});

  @override
  bool get isComplete => true; // completion checked in state

  @override
  State<GameModePanel> createState() => _GameModePanelState();
}

class _GameModePanelState extends ConvertSubPanelState<GameModePanel> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Game Mode',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Choose the game mode for which you want to convert data:'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: widget.gameModes
                  .map((gm) => RadioListTile<String>(
                        value: gm,
                        groupValue: _selected,
                        title: Text(gm),
                        onChanged: (v) => setState(() => _selected = v),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
