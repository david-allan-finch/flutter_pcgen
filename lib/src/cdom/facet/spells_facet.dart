// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.SpellsFacet

import '../base/cdom_object.dart';
import '../base/cdom_reference.dart';
import '../content/spell_like_ability.dart';
import '../enumeration/association_key.dart';
import '../enumeration/char_id.dart';
import '../../core/spell.dart';
import 'base/abstract_qualified_list_facet.dart';
import 'cdom_object_source_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Tracks [SpellLikeAbility] objects granted via SPELLS token on CDOMObjects.
class SpellsFacet extends AbstractQualifiedListFacet<SpellLikeAbility>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectSourceFacet cdomSourceFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final cdo = dfce.getCDOMObject();

    final mods = cdo.getListMods(Spell.spells);
    if (mods == null) return;

    for (final ref in mods) {
      final assocs = cdo.getListAssociations(Spell.spells, ref);
      final spells = (ref as CDOMReference<Spell>).getContainedObjects();
      for (final apo in assocs) {
        final times = apo.getAssociation(AssociationKey.getConstant('TIMES_PER_UNIT'));
        var timeunit = apo.getAssociation<String?>(AssociationKey.getConstant('TIME_UNIT'));
        timeunit ??= 'Day';
        final casterlevel = apo.getAssociation(AssociationKey.getConstant('CASTER_LEVEL'));
        final dcformula = apo.getAssociation(AssociationKey.getConstant('DC_FORMULA'));
        final book = apo.getAssociation(AssociationKey.getConstant('SPELLBOOK'));
        final ident = cdo.getQualifiedKey();
        for (final sp in spells) {
          final sla = SpellLikeAbility(
              sp, times, timeunit, book, casterlevel, dcformula, ident);
          sla.addAllPrerequisites(apo.getPrerequisiteList());
          add(id, sla, cdo);
        }
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  void init() {
    cdomSourceFacet.addDataFacetChangeListener(this);
  }
}
