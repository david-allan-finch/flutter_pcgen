import '../../base/pcgen_identifier.dart';

// Event fired when a scope-keyed facet's data changes.
class ScopeFacetChangeEvent<IDT extends PCGenIdentifier, S, T> {
  static const int dataAdded = 0;
  static const int dataRemoved = 1;

  final int eventID;
  final IDT charID;
  final S scope;
  final T node;
  final Object source;

  ScopeFacetChangeEvent(
      this.charID, this.scope, this.node, this.source, this.eventID);

  IDT getCharID() => charID;
  S getScope() => scope;
  T getCDOMObject() => node;
  int getEventType() => eventID;
  Object getSource() => source;
}
