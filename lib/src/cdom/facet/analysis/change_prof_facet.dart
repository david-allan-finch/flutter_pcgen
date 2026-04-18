// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.ChangeProfFacet

import '../../base/cdom_object.dart';
import '../../base/cdom_reference.dart';
import '../../content/change_prof.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../../../core/weapon_prof.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

/// Tracks ChangeProf objects that modify weapon proficiency types for a Player Character.
class ChangeProfFacet extends AbstractSourcedListFacet<CharID, ChangeProf>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final list = cdo.getListFor(ListKey.getConstant<ChangeProf>('CHANGEPROF'));
    if (list != null) {
      addAll(dfce.getCharID(), list, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns the WeaponProfs in the target group, after applying ChangeProf modifications.
  List<WeaponProf> getWeaponProfsInTarget(CharID id, CDOMReference<WeaponProf> master) {
    final type = master.getLSTformat(false);
    if (!type.startsWith('TYPE=')) {
      throw ArgumentError('Cannot get targets for: $type');
    }
    // TODO: Requires Globals.getContext() to resolve all WeaponProfs of the given TYPE.
    final aList = <WeaponProf>[];
    for (final cp in getSet(id)) {
      if (cp.result == master) {
        aList.addAll(cp.source.getContainedObjects());
      }
    }
    return aList;
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
