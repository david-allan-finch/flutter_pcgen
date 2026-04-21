// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.UnarmedDamageFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/cdom/inst/pc_class_level.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/formula_resolving_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';

/// Tracks Unarmed Damage info added to a Player Character (excluding class/class level).
class UnarmedDamageFacet extends AbstractSourcedListFacet<CharID, List<String>>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late RaceFacet raceFacet;
  late FormulaResolvingFacet formulaResolvingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    if (cdo is PCClass || cdo is PCClassLevel) return;
    final damage = cdo.getListFor(ListKey.getConstant<String>('UNARMED_DAMAGE'));
    if (damage != null) {
      add(dfce.getCharID(), damage, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns the unarmed damage string for the Race of the Player Character.
  String getUDamForRace(CharID id) {
    // TODO: Requires race SIZE formula resolution and Globals.adjustDamage().
    return '1d3';
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
