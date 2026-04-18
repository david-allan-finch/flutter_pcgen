// DataSetInitializedFacet is called once after a data set has been loaded,
// allowing facets to perform post-load initialization.
abstract interface class DataSetInitializedFacet {
  void initialize(dynamic context);
}
