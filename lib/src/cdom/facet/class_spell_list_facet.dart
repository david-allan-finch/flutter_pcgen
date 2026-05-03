// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.ClassSpellListFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/spell_list_facet.dart';

/// Manages Spell Lists granted to a Player Character via PCClass SPELLLIST.
class ClassSpellListFacet {
  late PlayerCharacterTrackingFacet trackingFacet;
  late SpellListFacet spellListFacet;

  /// Processes [pcc] and adds appropriate SpellList(s) to the PC.
  void process(CharID id, PCClass pcc) {
    final csc = pcc.getObject(CDOMObjectKey.getConstant('SPELLLIST_CHOICE'));
    if (csc == null) {
      addDefaultSpellList(id, pcc);
    } else {
      final pc = trackingFacet.getPC(id);
      for (final st in csc.driveChoice(pc)) {
        spellListFacet.add(id, st, pcc);
      }
    }
  }

  /// Adds the default SpellList for [pcc] to the Player Character.
  void addDefaultSpellList(CharID id, PCClass pcc) {
    spellListFacet.add(
        id, pcc.getObject(CDOMObjectKey.getConstant('CLASS_SPELLLIST')), pcc);
  }
}
