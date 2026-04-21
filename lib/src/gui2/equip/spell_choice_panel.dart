//
// Copyright 2013 (C) James Dempsey <jdempsey@users.sourceforge.net>
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
