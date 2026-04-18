// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/MasterUsableSkillFacet.java

import '../base/abstract_sourced_list_facet.dart';

/// MasterUsableSkillFacet stores the set of Skills that are usable untrained
/// and not exclusive, as determined from the loaded data set.
class MasterUsableSkillFacet extends AbstractSourcedListFacet<dynamic, dynamic> {
  dynamic dataSetInitializationFacet; // DataSetInitializationFacet

  /// Initializes the facet for the given LoadContext by adding all untrained,
  /// non-exclusive skills.
  void initialize(dynamic context) {
    dynamic id = context.getDataSetID();
    if (getCache(id) == null) {
      for (dynamic sk in context.getReferenceContext().getConstructedCDOMObjects(dynamic)) {
        bool exclusive = sk.getSafe('EXCLUSIVE') ?? false; // ObjectKey.EXCLUSIVE
        bool useUntrained = sk.getSafe('USE_UNTRAINED') ?? false; // ObjectKey.USE_UNTRAINED
        if (!exclusive && useUntrained) {
          add(id, sk, sk);
        }
      }
    }
  }

  void setDataSetInitializationFacet(dynamic dataSetInitializationFacet) {
    this.dataSetInitializationFacet = dataSetInitializationFacet;
  }

  void init() {
    dataSetInitializationFacet?.addDataSetInitializedFacet(this);
  }
}
