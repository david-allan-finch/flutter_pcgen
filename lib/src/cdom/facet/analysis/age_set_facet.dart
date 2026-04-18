// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.AgeSetFacet

import '../../enumeration/char_id.dart';
import '../../../core/age_set.dart';
import '../../../core/bio_set.dart';
import '../base/abstract_item_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../model/bio_set_facet.dart';
import '../model/race_facet.dart';

/// Stores the active [AgeSet] for a Player Character.
class AgeSetFacet extends AbstractItemFacet<CharID, AgeSet>
    implements DataFacetChangeListener<CharID, Object> {
  late RaceFacet raceFacet;
  late BioSetFacet bioSetFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, Object> dfce) {
    update(dfce.getCharID());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Object> dfce) {
    update(dfce.getCharID());
  }

  /// Recalculates and stores the current AgeSet for [id].
  void update(CharID id) {
    // TODO: determine age from channel/variable; resolve AgeSet from BioSet
    // For now this is a stub — requires age channel and BioSet lookup
  }

  /// Returns the index of the current AgeSet for [id].
  int getAgeSetIndex(CharID id) {
    final ageSet = get(id);
    if (ageSet == null) return 0;
    final bioSet = bioSetFacet.get(id);
    if (bioSet == null) return 0;
    return bioSet.getAgeSetIndex(ageSet);
  }
}
