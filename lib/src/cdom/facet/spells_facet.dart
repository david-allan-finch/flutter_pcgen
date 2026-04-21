// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.SpellsFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/content/spell_like_ability.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_qualified_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_source_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

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
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }

  void init() {
    cdomSourceFacet.addDataFacetChangeListener(this);
  }
}
