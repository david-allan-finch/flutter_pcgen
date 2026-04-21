// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.ActiveSpellsFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/character/character_spell.dart';
import 'package:flutter_pcgen/src/core/character/spell_book.dart';
import 'package:flutter_pcgen/src/core/character/spell_info.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/formula_resolving_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/spells_facet.dart';

/// Tracks active SPELLS (spell-like abilities from race/template) for a PC.
class ActiveSpellsFacet extends AbstractSourcedListFacet<CharID, CharacterSpell>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late RaceFacet raceFacet;
  late TemplateFacet templateFacet;
  late PlayerCharacterTrackingFacet trackingFacet;
  late FormulaResolvingFacet formulaResolvingFacet;
  late SpellsFacet spellsFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    process(dfce.getCharID());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    process(dfce.getCharID());
  }

  /// Global reset: rebuilds the active spell list for [id].
  void process(CharID id) {
    final race = raceFacet.get(id);
    removeAll(id, race);
    final pc = trackingFacet.getPC(id);
    for (final sla in spellsFacet.getQualifiedSet(id)) {
      final times = sla.getCastTimes();
      final resolvedTimes =
          formulaResolvingFacet.resolve(id, times, sla.getQualifiedKey()).toInt();
      final book = sla.getSpellBook();

      final cs = CharacterSpell(race, sla.getSpell());
      cs.setFixedCasterLevel(sla.getFixedCasterLevel());
      final si = cs.addInfo(0, resolvedTimes, book);
      si.setTimeUnit(sla.getCastTimeUnit());
      si.setFixedDC(sla.getDC());

      pc.addSpellBook(SpellBook(book, SpellBook.typeInnateSpells));
      add(id, cs, race);
    }
  }

  void init() {
    raceFacet.addDataFacetChangeListener(this);
    templateFacet.addDataFacetChangeListener(this);
  }
}
