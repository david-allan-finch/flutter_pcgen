import '../base/cdom_reference.dart';
import '../../core/armor_prof.dart';
import 'abstract_prof_provider.dart';

// An ArmorProfProvider grants armor proficiencies either by direct ArmorProf
// reference or by Equipment TYPE (e.g. TYPE=Armor.Light).
class ArmorProfProvider extends AbstractProfProvider<ArmorProf> {
  ArmorProfProvider(
    List<CDOMReference<ArmorProf>> profs,
    List<CDOMReference<dynamic>> equipTypes,
  ) : super(profs, equipTypes);

  // Returns true if this provider covers the given equipment's armor
  // proficiency or matches the equipment's type string.
  @override
  bool providesProficiencyFor(dynamic equipment) {
    return providesProficiency(equipment.getArmorProf() as ArmorProf) ||
        providesEquipmentType(equipment.getType() as String);
  }

  // Returns "ARMOR", used to build the LST format.
  @override
  String getSubType() => 'ARMOR';
}
