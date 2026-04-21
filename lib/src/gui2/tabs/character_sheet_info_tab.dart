// *
// CharacterSheetInfoTab.java Copyright James Dempsey, 2010
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.tabs.CharacterSheetInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/csheet/character_sheet_panel.dart';

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
