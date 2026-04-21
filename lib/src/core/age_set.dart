//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.core.AgeSet
import 'package:flutter_pcgen/src/cdom/base/bonus_container.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/base/transition_choice.dart';
import 'bonus/bonus_obj.dart';
import 'kit.dart';

// Represents an AGESET entry from the BioSettings game mode file.
// Groups bonuses and kit transitions applied when a character reaches an age bracket.
class AgeSet implements BonusContainer, Loadable {
  List<BonusObj>? _bonuses;
  List<TransitionChoice<Kit>>? _kits;
  String? _name;
  int _index = 0;
  String? _sourceUri;

  bool hasBonuses() => _bonuses != null && _bonuses!.isNotEmpty;

  int getIndex() => _index;
  void setAgeIndex(int ageSetIndex) => _index = ageSetIndex;

  List<BonusObj> getBonuses() =>
      _bonuses != null ? List.unmodifiable(_bonuses!) : const [];

  void addBonus(BonusObj bon) {
    _bonuses ??= [];
    _bonuses!.add(bon);
  }

  @override
  List<BonusObj> getRawBonusList() => _bonuses ?? const [];

  List<TransitionChoice<Kit>> getKits() =>
      _kits != null ? List.unmodifiable(_kits!) : const [];

  void addKit(TransitionChoice<Kit> tc) {
    _kits ??= [];
    _kits!.add(tc);
  }

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  String getKeyName() => _name ?? '';

  @override
  void setName(String name) => _name = name;

  @override
  String getDisplayName() => _name ?? '';

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;
}
