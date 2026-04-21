// Translation of pcgen.gui2.equip.SpellChoicePanel

import 'package:flutter/material.dart';

/// Panel for choosing a spell to embed in a piece of equipment.
class SpellChoicePanel extends StatefulWidget {
  final dynamic equipment;
  final dynamic character;

  const SpellChoicePanel({
    super.key,
    required this.equipment,
    required this.character,
  });

  @override
  State<SpellChoicePanel> createState() => _SpellChoicePanelState();
}

class _SpellChoicePanelState extends State<SpellChoicePanel> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Spell choice for equipment'));
  }
}
