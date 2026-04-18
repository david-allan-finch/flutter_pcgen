// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.UnlockedStatFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../../reference/cdom_single_ref.dart';
import '../../../core/pc_stat.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

/// Tracks [PCStat] objects that have been unlocked (released from a StatLock)
/// on a Player Character.
class UnlockedStatFacet extends AbstractSourcedListFacet<CharID, PCStat>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectConsolidationFacet consolidationFacet;

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final unlocked = cdo
        .getListFor(ListKey.getConstant<CDOMSingleRef<PCStat>>('UNLOCKED_STATS'));
    if (unlocked != null) {
      final charID = dfce.getCharID();
      for (final ref in unlocked) {
        add(charID, ref.get(), cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }
}
