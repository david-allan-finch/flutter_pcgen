import '../enumeration/grouping_state.dart';

// Holds the set of choices and related metadata for the CHOOSE system.
// Encodes/decodes to persistent LST strings.
abstract interface class ChooseInformation<T> {
  String getName();
  String getLSTformat();
  String getTitle();
  GroupingState getGroupingState();
  Type getReferenceClass();
  T decodeChoice(dynamic context, String persistentFormat);
  String encodeChoice(T choice);
  List<T> getSet(dynamic pc, dynamic driver);
  void restoreChoice(dynamic pc, dynamic owner, T choice);
  dynamic getChoiceActor();
  void setChoiceActor(dynamic actor);
  bool allowsPersistentStorage();
}
