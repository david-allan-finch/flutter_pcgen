// Controls whether Equipment Modifiers are required and/or allowed on equipment.
enum EqModControl {
  yes,
  no,
  required;

  bool getModifiersAllowed() => this != EqModControl.no;
  bool getModifiersRequired() => this == EqModControl.required;
}
