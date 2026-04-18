import '../../../enumeration/char_id.dart';

// Event fired when a two-scope facet's data changes.
class SubScopeFacetChangeEvent<S1, S2, T> {
  static const int dataAdded = 0;
  static const int dataRemoved = 1;

  final int eventID;
  final CharID charID;
  final S1 scope1;
  final S2 scope2;
  final T node;
  final Object source;

  SubScopeFacetChangeEvent(
      this.charID, this.scope1, this.scope2, this.node, this.source, this.eventID);

  CharID getCharID() => charID;
  S1 getScope1() => scope1;
  S2 getScope2() => scope2;
  T getCDOMObject() => node;
  int getEventType() => eventID;
  Object getSource() => source;
}
