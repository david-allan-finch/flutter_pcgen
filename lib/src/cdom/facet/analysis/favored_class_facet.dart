// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.analysis.FavoredClassFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/has_any_favored_class_facet.dart';

/// Tracks favored PCClass objects granted via FAVOREDCLASS tokens.
class FavoredClassFacet extends AbstractSourcedListFacet<CharID, PCClass>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late HasAnyFavoredClassFacet hasAnyFavoredClassFacet;
  late ClassFacet classFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final list = cdo.getListFor(
        ListKey.getConstant<CDOMReference<PCClass>>('FAVORED_CLASS'));
    if (list != null) {
      for (final ref in list) {
        addAll(dfce.getCharID(), ref.getContainedObjects(), cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns the effective favored class level for XP calculations.
  int getFavoredClassLevel(CharID id) {
    final aList = getSet(id);
    int level = 0;
    int max = 0;
    final isAny = hasAnyFavoredClassFacet.contains(id, true);
    for (final cl in aList) {
      for (final pcClass in classFacet.getSet(id)) {
        if (isAny) {
          max = [max, classFacet.getLevel(id, pcClass)].reduce((a, b) => a > b ? a : b);
        }
        if (cl.getKeyName() == pcClass.getKeyName()) {
          level += classFacet.getLevel(id, pcClass);
          break;
        }
      }
    }
    return level > max ? level : max;
  }
}
