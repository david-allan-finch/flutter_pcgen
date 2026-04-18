// Copyright (c) Thomas Parker, 2019.
//
// Translation of pcgen.cdom.facet.ScopedDistributionFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import '../formula/pcgen_scoped.dart';
import 'character_consolidation_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/var_scoped_facet.dart';

/// Routes PCGenScoped additions/removals to either [CharacterConsolidationFacet]
/// (for CDOMObjects) or [VarScopedFacet] (for non-CDOMObject PCGenScoped).
class ScopedDistributionFacet
    implements DataFacetChangeListener<CharID, PCGenScoped> {
  late CharacterConsolidationFacet characterConsolidationFacet;
  late VarScopedFacet varScopedFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCGenScoped> dfce) {
    if (dfce.getCDOMObject() is CDOMObject) {
      characterConsolidationFacet
          .dataAdded(dfce as DataFacetChangeEvent<CharID, CDOMObject>);
    } else {
      varScopedFacet.dataAdded(dfce);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCGenScoped> dfce) {
    if (dfce.getCDOMObject() is CDOMObject) {
      characterConsolidationFacet
          .dataRemoved(dfce as DataFacetChangeEvent<CharID, CDOMObject>);
    } else {
      varScopedFacet.dataRemoved(dfce);
    }
  }
}
