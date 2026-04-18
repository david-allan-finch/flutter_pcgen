import 'sub_scope_facet_change_event.dart';

abstract interface class SubScopeFacetChangeListener<S1, S2, T> {
  void dataAdded(SubScopeFacetChangeEvent<S1, S2, T> dfce);
  void dataRemoved(SubScopeFacetChangeEvent<S1, S2, T> dfce);
}
