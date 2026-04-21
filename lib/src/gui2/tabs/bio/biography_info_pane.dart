// Translation of pcgen.gui2.tabs.bio.BiographyInfoPane

import 'package:flutter/material.dart';
import 'bio_item.dart';

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
