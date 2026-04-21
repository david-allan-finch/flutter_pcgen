// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.SpellListToAvailableSpellFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/helper/available_spell.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/cdom/facet/available_spell_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/conditionally_available_spell_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/master_available_spell_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/spell_list_facet.dart';

/// Routes spells from master spell lists into [AvailableSpellFacet] (or
/// [ConditionallyAvailableSpellFacet] if they have prerequisites).
class SpellListToAvailableSpellFacet
    implements DataFacetChangeListener<CharID, CDOMList<Spell>> {
  late MasterAvailableSpellFacet masterAvailableSpellFacet;
  late SpellListFacet spellListFacet;
  late ConditionallyAvailableSpellFacet conditionallyAvailableSpellFacet;
  late AvailableSpellFacet availableSpellFacet;

  void _add(CharID id, AvailableSpell as_, Object source) {
    if (as_.hasPrerequisites()) {
      conditionallyAvailableSpellFacet.add(id, as_, source);
    } else {
      availableSpellFacet.add(
          id, as_.getSpelllist(), as_.getLevel(), as_.getSpell(), source);
    }
  }

  void _remove(CharID id, AvailableSpell as_, Object source) {
    if (as_.hasPrerequisites()) {
      conditionallyAvailableSpellFacet.remove(id, as_, source);
    } else {
      availableSpellFacet.remove(
          id, as_.getSpelllist(), as_.getLevel(), as_.getSpell(), source);
    }
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMList<Spell>> dfce) {
    final id = dfce.getCharID();
    final list = dfce.getCDOMObject();
    final spells = masterAvailableSpellFacet.getSet(id.getDatasetID());
    for (final as_ in spells) {
      if (as_.getSpelllist() == list) {
        _add(id, as_, this);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMList<Spell>> dfce) {
    final id = dfce.getCharID();
    final list = dfce.getCDOMObject();
    final spells = masterAvailableSpellFacet.getSet(id.getDatasetID());
    for (final as_ in spells) {
      if (as_.getSpelllist() == list) {
        _remove(id, as_, this);
      }
    }
  }

  void init() {
    spellListFacet.addDataFacetChangeListener(this);
  }
}
