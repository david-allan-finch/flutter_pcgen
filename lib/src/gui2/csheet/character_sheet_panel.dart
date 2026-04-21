// Translation of pcgen.gui2.csheet.CharacterSheetPanel

import 'package:flutter/material.dart';

/// Panel that displays a rendered character sheet (HTML output).
class CharacterSheetPanel extends StatefulWidget {
  final dynamic character;

  const CharacterSheetPanel({super.key, required this.character});

  @override
  State<CharacterSheetPanel> createState() => _CharacterSheetPanelState();
}

class _CharacterSheetPanelState extends State<CharacterSheetPanel> {
  String _htmlContent = '';

  @override
  void initState() {
    super.initState();
    _loadSheet();
  }

  void _loadSheet() {
    // In the full port, this would invoke the output engine
    setState(() => _htmlContent = '<html><body>Character Sheet</body></html>');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _htmlContent.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Text(_htmlContent),
                ),
        ),
      ],
    );
  }
}
