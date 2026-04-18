import '../base/cdom_object.dart';

// Interface for objects that grant equipment proficiencies.
abstract interface class ProfProvider<T extends CDOMObject> {
  bool providesProficiencyFor(dynamic equipment);
  bool providesProficiency(T prof);
  bool providesEquipmentType(String typeString);
  String getLstFormat();
}
