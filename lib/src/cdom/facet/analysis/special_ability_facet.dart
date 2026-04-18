// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.analysis.SpecialAbilityFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../../../core/special_ability.dart';
import '../base/abstract_qualified_list_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../player_character_tracking_facet.dart';

/// Tracks SpecialAbility (SAB) objects on a Player Character.
class SpecialAbilityFacet extends AbstractQualifiedListFacet<SpecialAbility>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  /// Returns resolved SpecialAbility objects for the given source.
  List<SpecialAbility> getResolved(CharID id, Object source) {
    final pc = trackingFacet.getPC(id);
    return getQualifiedSet(id, source)
        .map((sa) => sa.resolve(pc, source))
        .toList();
  }

  /// Returns processed SpecialAbility objects via the given actor.
  List<T> getAllResolved<T>(CharID id, T Function(SpecialAbility, Object) actor) {
    return actOnQualifiedSet(id, actor);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    addAll(dfce.getCharID(),
        cdo.getSafeListFor(ListKey.getConstant<SpecialAbility>('SAB')), cdo);
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
