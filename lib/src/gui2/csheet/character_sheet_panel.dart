//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
