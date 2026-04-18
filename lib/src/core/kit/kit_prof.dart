import '../../cdom/reference/cdom_single_ref.dart';
import '../../core/kit.dart';
import '../../core/player_character.dart';
import '../../core/weapon_prof.dart';
import 'base_kit.dart';

// Kit task that grants weapon proficiencies to a PC.
final class KitProf extends BaseKit {
  int? choiceCount;
  final List<CdomSingleRef<WeaponProf>> _profList = [];
  bool? racialProf;

  // Transient state
  List<WeaponProf>? _weaponProfs;

  bool isRacial() => racialProf == true;
  void setRacialProf(bool argRacial) { racialProf = argRacial; }
  bool? getRacialProf() => racialProf;

  void setCount(int quan) { choiceCount = quan; }
  int? getCount() => choiceCount;
  int getSafeCount() => choiceCount ?? 1;

  void addProficiency(CdomSingleRef<WeaponProf> ref) { _profList.add(ref); }
  List<CdomSingleRef<WeaponProf>> getProficiencies() => List.unmodifiable(_profList);

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _weaponProfs = null;

    if (isRacial()) {
      final pcRace = aPC.getRace();
      if (pcRace == null) {
        warnings.add('PROF: PC has no race');
        return false;
      }
    } else {
      final pcClasses = aPC.getClassSet();
      if (pcClasses.isEmpty) {
        warnings.add('PROF: No owning class found.');
        return false;
      }
    }

    for (final profKey in _profList) {
      final wp = profKey.get();
      _weaponProfs ??= [];
      _weaponProfs!.add(wp);
    }
    return false;
  }

  @override
  void apply(PlayerCharacter aPC) {
    if (_weaponProfs == null) return;
    for (final wp in _weaponProfs!) {
      aPC.addWeaponProf(wp);
    }
  }

  @override
  String getObjectName() => 'Proficiencies';

  @override
  String toString() {
    final sb = StringBuffer();
    if (getSafeCount() != 1 || _profList.length != 1) {
      sb.write('${getSafeCount()} of ');
    }
    sb.write(_profList.map((r) => r.toString()).join(', '));
    return sb.toString();
  }
}
