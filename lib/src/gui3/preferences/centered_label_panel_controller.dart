// Translation of pcgen.gui3.preferences.CenteredLabelPanelController

import 'package:flutter/material.dart';

/// A simple panel that shows a centred label — used as a placeholder
/// for preference sections that are not yet implemented.
class CenteredLabelPanelController extends StatelessWidget {
  final String label;

  const CenteredLabelPanelController({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}
