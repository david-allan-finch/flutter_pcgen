//
// Copyright 2006 (C) Aaron Divinsky <boomer70@yahoo.com>
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
// Translation of pcgen.core.kit.KitBio
import '../kit.dart';
import '../player_character.dart';
import 'base_kit.dart';

class KitBio extends BaseKit {
  String? _characterName;
  int? _characterAge;
  List<String>? _genderNames; // gender name strings
  String? _selectedGender;

  void setCharacterName(String name) { _characterName = name; }
  String? getCharacterName() => _characterName;

  void setCharacterAge(int age) { _characterAge = age; }
  int? getCharacterAge() => _characterAge;

  void addGender(String gender) {
    _genderNames ??= [];
    if (_genderNames!.contains(gender)) throw ArgumentError('Cannot add Gender: $gender twice');
    _genderNames!.add(gender);
  }

  List<String>? getGenders() => _genderNames;

  @override
  void apply(PlayerCharacter aPC) {
    if (_characterName != null) aPC.setName(_characterName!);
    if (_characterAge != null) aPC.setAge(_characterAge!);
    if (_selectedGender != null) aPC.setGender(_selectedGender!);
  }

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _selectedGender = null;
    if (_genderNames != null && _genderNames!.isNotEmpty) {
      _selectedGender = _genderNames![0]; // single or first option
    }
    apply(aPC);
    return true;
  }

  @override
  String getObjectName() => 'Bio Settings';

  @override
  String toString() {
    final buf = StringBuffer();
    if (_characterName != null) buf.write(' Name: $_characterName');
    if (_genderNames != null) buf.write(' Gender: ${_genderNames!.join(', ')}');
    if (_characterAge != null) buf.write(' Age: $_characterAge');
    return buf.toString();
  }
}
