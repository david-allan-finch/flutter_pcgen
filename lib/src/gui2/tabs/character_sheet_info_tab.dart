// Translation of pcgen.gui2.tabs.CharacterSheetInfoTab

import 'package:flutter/material.dart';
import '../csheet/character_sheet_panel.dart';

/// Tab panel that shows the rendered character sheet.
class CharacterSheetInfoTab extends StatefulWidget {
  const CharacterSheetInfoTab({super.key});

  @override
  State<CharacterSheetInfoTab> createState() => CharacterSheetInfoTabState();
}

class CharacterSheetInfoTabState extends State<CharacterSheetInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return const Center(child: Text('No character loaded'));
    }
    return CharacterSheetPanel(character: _character);
  }
}
