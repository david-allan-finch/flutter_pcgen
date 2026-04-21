//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.bio.BiographyInfoPane

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/tabs/bio/bio_item.dart';

/// Panel showing character biography fields (name, age, gender, etc.).
class BiographyInfoPane extends StatefulWidget {
  final dynamic character;

  const BiographyInfoPane({super.key, this.character});

  @override
  State<BiographyInfoPane> createState() => _BiographyInfoPaneState();
}

class _BiographyInfoPaneState extends State<BiographyInfoPane> {
  static const List<String> _fields = [
    'Name', 'Tab Name', 'Player Name', 'Gender', 'Handedness',
    'Age', 'Skin Color', 'Eye Color', 'Hair Color', 'Hair Style',
    'Height', 'Weight', 'Region', 'Birthplace', 'Personality',
    'Phobias', 'Interests', 'Speech Pattern', 'Catch Phrase', 'Residence',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _fields
          .map((f) => BioItem(label: f))
          .toList(),
    );
  }
}
