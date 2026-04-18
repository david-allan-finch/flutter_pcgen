// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.ActiveSpellsFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import '../../core/character/character_spell.dart';
import '../../core/character/spell_book.dart';
import '../../core/character/spell_info.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'formula_resolving_facet.dart';
import 'model/race_facet.dart';
import 'model/template_facet.dart';
import 'player_character_tracking_facet.dart';
import 'spells_facet.dart';

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
