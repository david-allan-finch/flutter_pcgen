// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.UnarmedDamageFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../../../core/pc_class.dart';
import '../../inst/pc_class_level.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../formula_resolving_facet.dart';
import '../model/race_facet.dart';

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
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
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
