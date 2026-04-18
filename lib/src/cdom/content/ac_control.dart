import '../base/concrete_prereq_object.dart';

// Stores an AC (Armor Class) control type; used to track how AC is calculated.
class ACControl extends ConcretePrereqObject {
  final String _type;

  ACControl(String acType) : _type = acType;

  String getType() => _type;
}
