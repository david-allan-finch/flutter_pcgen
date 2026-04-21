//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.inst.EqSizePenalty
import 'package:flutter_pcgen/src/core/bonus/bonus_obj.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

class EqSizePenalty implements Loadable {
  String? _sourceURI;
  String? _penaltyName;
  List<BonusObj>? _bonusList;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) { _penaltyName = name; }

  @override
  String? getDisplayName() => _penaltyName;

  @override
  String? getKeyName() => _penaltyName;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void addBonus(BonusObj bon) {
    _bonusList ??= [];
    _bonusList!.add(bon);
  }

  List<BonusObj> getBonuses() =>
      _bonusList == null ? const [] : List.unmodifiable(_bonusList!);
}
