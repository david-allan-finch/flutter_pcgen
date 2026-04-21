// Copyright (c) Tom Parker, 2010.
//
// Translation of pcgen.cdom.facet.AppliedBonusFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/bonus/bonus_obj.dart';
import 'added_bonus_facet.dart';
import 'base/abstract_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/race_facet.dart';
import 'prerequisite_facet.dart';
import 'saveable_bonus_facet.dart';

/// Tracks the active [BonusObj] objects on a Player Character, honoring
/// prerequisites. Listens to CDOMObject additions/removals and evaluates
/// BONUS: tokens plus any side-effect bonuses.
class AppliedBonusFacet extends AbstractListFacet<CharID, BonusObj>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late AddedBonusFacet addedBonusFacet;
  late SaveableBonusFacet saveableBonusFacet;
  late PrerequisiteFacet prerequisiteFacet;
  late RaceFacet raceFacet;

  void init() {
    raceFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final cdo = dfce.getCDOMObject();
    _processAdd(id, cdo,
        cdo.getSafeListFor(ListKey.getConstant<BonusObj>('BONUS')));
    _processAdd(id, cdo, addedBonusFacet.getSet(id, cdo).toList());
    _processAdd(id, cdo, saveableBonusFacet.getSet(id, cdo).toList());
  }

  void _processAdd(
      CharID id, CDOMObject cdo, List<BonusObj> bonusList) {
    for (final bonus in bonusList) {
      if (prerequisiteFacet.qualifies(id, bonus, cdo)) {
        add(id, bonus);
      } else {
        remove(id, bonus);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final cdo = dfce.getCDOMObject();
    _processRemove(id,
        cdo.getSafeListFor(ListKey.getConstant<BonusObj>('BONUS')));
    _processRemove(id, addedBonusFacet.getSet(id, cdo).toList());
    _processRemove(id, saveableBonusFacet.getSet(id, cdo).toList());
  }

  void _processRemove(CharID id, List<BonusObj> bonusList) {
    for (final bonus in bonusList) {
      remove(id, bonus);
    }
  }
}
