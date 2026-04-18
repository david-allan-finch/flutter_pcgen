import '../../base/pcgen_identifier.dart';
import 'data_facet_change_event.dart';

abstract interface class DataFacetChangeListener<IDT extends PCGenIdentifier, T> {
  void dataAdded(DataFacetChangeEvent<IDT, T> dfce);
  void dataRemoved(DataFacetChangeEvent<IDT, T> dfce);
}
