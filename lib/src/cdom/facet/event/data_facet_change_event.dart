import '../../base/pcgen_identifier.dart';

// Event fired when a facet's data changes for a given PCGenIdentifier.
class DataFacetChangeEvent<IDT extends PCGenIdentifier, T> {
  static const int dataAdded = 0;
  static const int dataRemoved = 1;

  final int eventID;
  final IDT charID;
  final T node;
  final Object source;

  DataFacetChangeEvent(this.charID, this.node, this.source, this.eventID);

  IDT getCharID() => charID;
  T getCDOMObject() => node;
  int getEventType() => eventID;
  Object getSource() => source;
}
