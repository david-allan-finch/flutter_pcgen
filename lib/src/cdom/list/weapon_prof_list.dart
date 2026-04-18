import '../base/cdom_list_object.dart';
import '../../core/weapon_prof.dart';

// A named list of weapon proficiencies.
class WeaponProfList extends CDOMListObject<WeaponProf> {
  @override
  Type get listClass => WeaponProf;

  @override
  bool isType(String type) => false;
}
