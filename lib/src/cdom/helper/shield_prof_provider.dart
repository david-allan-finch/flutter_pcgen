import '../base/cdom_reference.dart';
import '../../core/shield_prof.dart';
import 'abstract_prof_provider.dart';

// A ShieldProfProvider grants shield proficiencies either by direct ShieldProf
// reference or by Equipment TYPE (e.g. TYPE=Shield.Heavy).
class ShieldProfProvider extends AbstractProfProvider<ShieldProf> {
  ShieldProfProvider(
    List<CDOMReference<ShieldProf>> profs,
    List<CDOMReference<dynamic>> equipTypes,
  ) : super(profs, equipTypes);

  // Returns true if this provider covers the given equipment's shield
  // proficiency or matches the equipment's type string.
  @override
  bool providesProficiencyFor(dynamic equipment) {
    return providesProficiency(equipment.getShieldProf() as ShieldProf) ||
        providesEquipmentType(equipment.getType() as String);
  }

  // Returns "SHIELD", used to build the LST format.
  @override
  String getSubType() => 'SHIELD';
}
