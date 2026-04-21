//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.kit.KitProf
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/weapon_prof.dart';
import 'base_kit.dart';

// Kit task that grants weapon proficiencies to a PC.
final class KitProf extends BaseKit {
  int? choiceCount;
  final List<CDOMSingleRef<WeaponProf>> _profList = [];
  bool? racialProf;

  // Transient state
  List<WeaponProf>? _weaponProfs;

  bool isRacial() => racialProf == true;
  void setRacialProf(bool argRacial) { racialProf = argRacial; }
  bool? getRacialProf() => racialProf;

  void setCount(int quan) { choiceCount = quan; }
  int? getCount() => choiceCount;
  int getSafeCount() => choiceCount ?? 1;

  void addProficiency(CDOMSingleRef<WeaponProf> ref) { _profList.add(ref); }
  List<CDOMSingleRef<WeaponProf>> getProficiencies() => List.unmodifiable(_profList);

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
