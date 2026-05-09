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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/csheet/html_sheet_panel.dart';
import 'package:flutter_pcgen/src/gui2/csheet/character_sheet_panel.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

/// Tab panel that shows the character sheet.
/// - Mobile (Android/iOS): renders HTML inline via WebView.
/// - Desktop (Windows/macOS/Linux): uses the native Flutter widget sheet,
///   with an "Open HTML Sheet" button to view in the default browser.
class CharacterSheetInfoTab extends StatelessWidget {
  const CharacterSheetInfoTab({super.key});

  static bool get _useWebView =>
      Platform.isAndroid || Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (_useWebView) return const HtmlSheetPanel();

    // Desktop: Flutter widget sheet
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        if (character == null) {
          return const Center(child: Text('No character selected.'));
        }
        return CharacterSheetPanel(character: character);
      },
    );
  }
}
