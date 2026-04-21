// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.AddedTemplateFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/prerequisite_facet.dart';

/// Tracks [PCTemplate] objects added to a Player Character via TEMPLATE tokens.
class AddedTemplateFacet extends AbstractSourcedListFacet<CharID, PCTemplate>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late PrerequisiteFacet prerequisiteFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  /// Selects and records templates from [po]'s TEMPLATE list for [id].
  List<PCTemplate> select(CharID id, CDOMObject po) {
    final list = <PCTemplate>[];
    removeAllFromSource(id, po);
    final pc = trackingFacet.getPC(id);
    if (!pc.isImporting()) {
      for (final ref in po.getSafeListFor(
          ListKey.getConstant<CDOMReference<PCTemplate>>('TEMPLATE'))) {
        for (final pct in ref.getContainedObjects()) {
          add(id, pct, po);
          list.add(pct);
        }
      }
      final added = <PCTemplate>[];
      for (final ref in po.getSafeListFor(
          ListKey.getConstant<CDOMReference<PCTemplate>>('TEMPLATE_ADDCHOICE'))) {
        added.addAll(ref.getContainedObjects());
      }
      for (final ref in po.getSafeListFor(
          ListKey.getConstant<CDOMReference<PCTemplate>>('TEMPLATE_CHOOSE'))) {
        final chooseList = [...added, ...ref.getContainedObjects()];
        final selected = chooseTemplate(po, chooseList, true, id);
        if (selected != null) {
          add(id, selected, po);
          list.add(selected);
        }
      }
    }
    return list;
  }

  /// Returns templates to be removed via TEMPLATE:REMOVE.
  List<PCTemplate> remove(CharID id, CDOMObject po) {
    final list = <PCTemplate>[];
    final pc = trackingFacet.getPC(id);
    if (!pc.isImporting()) {
      for (final ref in po.getSafeListFor(
          ListKey.getConstant<CDOMReference<PCTemplate>>('REMOVE_TEMPLATES'))) {
        list.addAll(ref.getContainedObjects());
      }
    }
    return list;
  }

  /// Drives template selection from [list], filtering by prerequisites.
  PCTemplate? chooseTemplate(
      CDOMObject anOwner, List<PCTemplate> list, bool forceChoice, CharID id) {
    final available = [
      for (final pct in list)
        if (prerequisiteFacet.qualifies(id, pct, anOwner)) pct
    ];
    if (available.isEmpty) return null;
    if (available.length == 1) return available[0];
    final pc = trackingFacet.getPC(id);
    final selected = pc.chooseFromList(
        'Template Choice (${anOwner.getDisplayName()})', available, 1,
        forceChoice: forceChoice);
    return selected.length == 1 ? selected[0] : null;
  }

  /// Returns templates sourced from [cdo] currently tracked for [id].
  List<PCTemplate> getFromSource(CharID id, CDOMObject cdo) {
    final result = <PCTemplate>[];
    final map = getCachedMap(id);
    if (map != null) {
      for (final entry in map.entries) {
        if (entry.value.contains(cdo)) {
          result.add(entry.key);
        }
      }
    }
    return result;
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final cdo = dfce.getCDOMObject();
    final pc = trackingFacet.getPC(id);
    final list = getFromSource(id, cdo);
    if (list.isEmpty) {
      for (final pct in select(id, cdo)) {
        pc.addTemplate(pct);
      }
      for (final pct in remove(id, cdo)) {
        pc.removeTemplate(pct);
      }
    } else {
      for (final pct in list) {
        pc.addTemplate(pct);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final id = dfce.getCharID();
    final pc = trackingFacet.getPC(id);
    final list = getFromSource(id, cdo);
    for (final pct in list) {
      pc.removeTemplate(pct);
    }
    removeAllFromSource(id, cdo);
    final refList = cdo.getListFor(
        ListKey.getConstant<CDOMReference<PCTemplate>>('TEMPLATE'));
    if (refList != null) {
      for (final ref in refList) {
        for (final pct in ref.getContainedObjects()) {
          pc.removeTemplate(pct);
        }
      }
    }
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
