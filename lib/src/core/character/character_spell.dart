//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.character.CharacterSpell
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/core/character/spell_info.dart';

// Associates a Spell with a source (PCClass/Domain/Race) and a list of SpellInfos.
final class CharacterSpell implements Comparable<CharacterSpell> {
  final List<SpellInfo> _infoList = [];
  final CDOMObject owner;
  final Spell? spell;
  String? fixedCasterLevel;

  CharacterSpell(this.owner, this.spell);

  List<SpellInfo> getInfoList() => _infoList;
  Spell? getSpell() => spell;
  String? getFixedCasterLevel() => fixedCasterLevel;
  void setFixedCasterLevel(String? v) { fixedCasterLevel = v; }

  bool isSpecialtySpell(PlayerCharacter pc) {
    if (spell == null) return false;
    if (owner is Domain) return true;
    if (owner is PCClass) {
      // SpellCountCalc.isSpecialtySpell stub
      return false;
    }
    return false;
  }

  int getInfoIndexFor(PlayerCharacter pc, String bookName, int level, int specialty) {
    if (_infoList.isEmpty) return -1;
    bool sp = specialty == 1 && isSpecialtySpell(pc);
    for (int i = 0; i < _infoList.length; i++) {
      final s = _infoList[i];
      if ((bookName.isEmpty || bookName == s.book) &&
          (level == -1 || s.actualLevel == level) &&
          (specialty == -1 || sp)) {
        return i;
      }
    }
    return -1;
  }

  SpellInfo? getSpellInfoFor(String bookName, int level, [List<Ability>? featList]) {
    if (_infoList.isEmpty) return null;
    for (final s in _infoList) {
      if ((bookName.isEmpty || bookName == s.book) &&
          (level == -1 || s.actualLevel == level) &&
          (featList == null ||
              (featList.isEmpty && (s.featList == null || s.featList!.isEmpty)) ||
              (s.featList != null && featList.toString() == s.featList.toString()))) {
        return s;
      }
    }
    return null;
  }

  bool hasSpellInfoFor(dynamic levelOrBook) {
    if (_infoList.isEmpty) return false;
    if (levelOrBook is int) {
      return _infoList.any((s) => s.actualLevel == levelOrBook);
    }
    if (levelOrBook is String) {
      return _infoList.any((s) => s.book == levelOrBook);
    }
    return false;
  }

  SpellInfo addInfo(int level, int times, String book,
      {int? origLevel, List<Ability>? featList}) {
    final si = SpellInfo(this, origLevel ?? level, level, times, book);
    if (featList != null) si.addFeatsToList(featList);
    _infoList.add(si);
    return si;
  }

  void removeSpellInfo(SpellInfo? x) {
    if (x != null) _infoList.remove(x);
  }

  String getVariableSource(PlayerCharacter pc) {
    if (owner is Domain) return 'CLASS:'; // simplified
    if (owner is PCClass) return 'CLASS:${owner.getKeyName()}';
    if (owner is Race) return 'RACE:${owner.getKeyName()}';
    return '';
  }

  @override
  int compareTo(CharacterSpell obj) {
    final s = spell;
    final os = obj.spell;
    int compare = (s == null || os == null) ? 0 : s.compareTo(os);
    if (compare == 0) {
      final fcl = fixedCasterLevel;
      final ofcl = obj.fixedCasterLevel;
      if (fcl == null && ofcl != null) compare = -1;
      else if (fcl != null && ofcl == null) compare = 1;
      else if (fcl != null && ofcl != null) compare = fcl.compareTo(ofcl);
    }
    if (compare == 0) compare = owner.getKeyName().compareTo(obj.owner.getKeyName());
    if (compare == 0) {
      compare = _infoList.length.compareTo(obj._infoList.length);
      if (compare == 0) {
        for (int i = 0; i < _infoList.length; i++) {
          compare = _infoList[i].compareTo(obj._infoList[i]);
          if (compare != 0) break;
        }
      }
    }
    return compare;
  }

  String _getName() {
    final buf = StringBuffer(owner.toString());
    if (spell != null) buf.write(':${spell!.getDisplayName()}');
    return buf.toString();
  }

  @override
  bool operator ==(Object obj) =>
      obj is CharacterSpell && obj._getName() == _getName();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => spell?.getDisplayName() ?? '';
}
