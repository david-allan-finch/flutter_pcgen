import '../../base/pcgen_identifier.dart';
import 'scope_facet_change_event.dart';

abstract interface class ScopeFacetChangeListener<IDT extends PCGenIdentifier, S, T> {
  void dataAdded(ScopeFacetChangeEvent<IDT, S, T> dfce);
  void dataRemoved(ScopeFacetChangeEvent<IDT, S, T> dfce);
}
