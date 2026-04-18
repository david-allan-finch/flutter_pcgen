// Event fired when an association bonus value changes for a character.
class AssociationChangeEvent {
  final Object source;
  final dynamic charID;
  final dynamic associationKey;
  final dynamic oldValue;
  final dynamic newValue;

  AssociationChangeEvent(this.source, this.charID, this.associationKey,
      this.oldValue, this.newValue);

  Object getSource() => source;
  dynamic getCharID() => charID;
  dynamic getAssociationKey() => associationKey;
  dynamic getOldValue() => oldValue;
  dynamic getNewValue() => newValue;
}
