// Translation of pcgen.gui2.converter.panel.StartupPanel

import 'package:flutter/material.dart';
import 'convert_sub_panel.dart';

/// First wizard step: welcome/intro message for the converter.
class StartupPanel extends ConvertSubPanel {
  const StartupPanel({super.key});

  @override
  bool get isComplete => true;

  @override
  State<StartupPanel> createState() => _StartupPanelState();
}

class _StartupPanelState extends ConvertSubPanelState<StartupPanel> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome to the PCGen Data Converter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 16),
          Text(
            'This tool will help you convert LST data files from an older format '
            'to the current PCGen format.\n\n'
            'Click Next to begin.',
          ),
        ],
      ),
    );
  }
}
