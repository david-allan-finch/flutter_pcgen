// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.DataSetInitializationFacet

/// Interface for facets that need to be notified when a dataset is loaded.
abstract interface class DataSetInitializedFacet {
  void initialize(dynamic context);
}

/// Manages dataset-initialized facets, calling [initialize] when data loads.
class DataSetInitializationFacet {
  final List<DataSetInitializedFacet> _facetList = [];

  void addDataSetInitializedFacet(DataSetInitializedFacet cif) {
    _facetList.add(cif);
  }

  void initialize(dynamic context) {
    for (final cif in _facetList) {
      cif.initialize(context);
    }
  }
}
