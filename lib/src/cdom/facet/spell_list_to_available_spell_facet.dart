// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.SpellListToAvailableSpellFacet

import '../base/cdom_list.dart';
import '../enumeration/char_id.dart';
import '../helper/available_spell.dart';
import '../../core/spell.dart';
import 'available_spell_facet.dart';
import 'conditionally_available_spell_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'master_available_spell_facet.dart';
import 'spell_list_facet.dart';

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
