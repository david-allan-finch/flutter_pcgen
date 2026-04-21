// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.AvailableSpellInputFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/helper/available_spell.dart';
import 'package:flutter_pcgen/src/cdom/list/class_spell_list.dart';
import 'package:flutter_pcgen/src/cdom/list/domain_spell_list.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/cdom/facet/available_spell_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/conditionally_available_spell_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Processes spell entries on CDOMObjects and routes them to either
/// [AvailableSpellFacet] (unconditional) or [ConditionallyAvailableSpellFacet]
/// (prerequisite-gated).
class AvailableSpellInputFacet
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late ConditionallyAvailableSpellFacet conditionallyAvailableSpellFacet;
  late AvailableSpellFacet availableSpellFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final id = dfce.getCharID();
    for (final ref in cdo.getModifiedLists()) {
      _processListRef(id, cdo, ref);
    }
  }

  void _processListRef(
      CharID id, CDOMObject cdo, CDOMReference<CDOMList<dynamic>> listref) {
    for (final list in listref.getContainedObjects()) {
      if (list is! ClassSpellList && list is! DomainSpellList) continue;
      final spellList = list as CDOMList<Spell>;
      _processList(id, spellList, listref, cdo);
    }
  }

  void _processList(CharID id, CDOMList<Spell> spellList,
      CDOMReference<CDOMList<dynamic>> listref, CDOMObject cdo) {
    final spellListRef = listref as CDOMReference<CDOMList<Spell>>;
    for (final objref in cdo.getListMods(spellListRef)) {
      for (final apo in cdo.getListAssociations(listref, objref)) {
        final spells = objref.getContainedObjects();
        final lvl = apo.getAssociation(AssociationKey.spellLevel) as int?;

        if (apo.hasPrerequisites()) {
          final prereqs = apo.getPrerequisiteList();
          for (final spell in spells) {
            final as_ = AvailableSpell(spellList, spell, lvl);
            as_.addAllPrerequisites(prereqs);
            conditionallyAvailableSpellFacet.add(id, as_, cdo);
          }
        } else {
          for (final spell in spells) {
            availableSpellFacet.add(id, spellList, lvl ?? 0, spell, cdo);
          }
        }
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final source = dfce.getCDOMObject();
    conditionallyAvailableSpellFacet.removeAllFromSource(id, source);
    availableSpellFacet.removeAllFromSource(id, source);
  }
}
