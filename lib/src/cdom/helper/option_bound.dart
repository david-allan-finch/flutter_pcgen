//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.helper.OptionBound
import 'package:flutter_pcgen/src/core/player_character.dart';

// Represents an inclusive range of values defined by two optional Formulas.
class OptionBound {
  final dynamic _minOption; // Formula?
  final dynamic _maxOption; // Formula?

  OptionBound(dynamic min, dynamic max)
      : _minOption = min,
        _maxOption = max;

  bool isOption(PlayerCharacter pc, int value) {
    if (_minOption != null &&
        _minOption.resolve(pc, '').toInt() > value) return false;
    if (_maxOption != null &&
        _maxOption.resolve(pc, '').toInt() < value) return false;
    return true;
  }

  dynamic getOptionMin() => _minOption;
  dynamic getOptionMax() => _maxOption;
}
