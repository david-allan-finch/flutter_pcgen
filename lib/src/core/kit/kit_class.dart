//
// Copyright 2005 (C) Aaron Divinsky <boomer70@yahoo.com>
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
// Translation of pcgen.core.kit.KitClass
import '../../base/formula/formula.dart';
import '../../cdom/base/cdom_reference.dart';
import '../../cdom/reference/cdom_single_ref.dart';
import '../../core/kit.dart';
import '../../core/pc_class.dart';
import '../../core/player_character.dart';
import '../../core/sub_class.dart';
import '../../core/prereq/prereq_handler.dart';
import 'base_kit.dart';

// Kit task that adds class levels to a PC, optionally setting a subclass.
class KitClass extends BaseKit {
  CdomSingleRef<PCClass>? pcClass;
  Formula? levelFormula;
  CdomReference<SubClass>? subClass;

  // Transient state (not cloned)
  PCClass? _theClass;
  String? _theOrigSubClass;
  int _theLevel = -1;
  bool _doLevelAbilities = true;

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _theLevel = -1;
    _doLevelAbilities = true;

    _theClass = pcClass!.get();
    _theOrigSubClass = aPC.getSubClassName(_theClass!);
    _applySubClass(aPC);

    if (!PrereqHandler.passesAll(_theClass!, aPC, aKit)) {
      warnings.add('CLASS: Not qualified for class "${_theClass!.getKeyName()}".');
      return false;
    }

    _doLevelAbilities = aKit.doLevelAbilities();
    _theLevel = levelFormula!.resolve(aPC, '').toInt();
    _addLevel(aPC, _theLevel, _theClass!, _doLevelAbilities);
    return true;
  }

  void _applySubClass(PlayerCharacter aPC) {
    if (subClass != null) {
      PCClass? heldClass = aPC.getClassKeyed(_theClass!.getKeyName());
      if (heldClass == null) {
        aPC.incrementClassLevel(0, _theClass!);
        heldClass = aPC.getClassKeyed(_theClass!.getKeyName());
      }
      aPC.setSubClassKey(heldClass!, subClass!.getLSTformat(false));
    }
  }

  @override
  void apply(PlayerCharacter aPC) {
    _applySubClass(aPC);
    _addLevel(aPC, _theLevel, _theClass!, _doLevelAbilities);
    if (_theOrigSubClass != null) {
      aPC.setSubClassKey(_theClass!, _theOrigSubClass!);
    }
    _theClass = null;
  }

  void _addLevel(PlayerCharacter pc, int numLevels, PCClass aClass, bool doLevelAbilitiesIn) {
    final tempDoLevelAbilities = pc.doLevelAbilities();
    pc.setDoLevelAbilities(doLevelAbilitiesIn);
    pc.incrementClassLevel(numLevels, aClass, true);
    pc.setDoLevelAbilities(tempDoLevelAbilities);
  }

  @override
  String getObjectName() => 'Classes';

  void setPcclass(CdomSingleRef<PCClass> ref) { pcClass = ref; }
  CdomReference<PCClass>? getPcclass() => pcClass;
  void setLevel(Formula formula) { levelFormula = formula; }
  Formula? getLevel() => levelFormula;
  void setSubClass(CdomReference<SubClass> sc) { subClass = sc; }
  CdomReference<SubClass>? getSubClass() => subClass;

  @override
  String toString() {
    final ret = StringBuffer(pcClass?.getLSTformat(false) ?? '');
    if (subClass != null) ret.write('(${subClass!.getLSTformat(false)})');
    ret.write(levelFormula);
    return ret.toString();
  }
}
