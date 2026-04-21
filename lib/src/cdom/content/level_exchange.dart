//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.LevelExchange
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';

// Stores the constraints for a class level exchange.
class LevelExchange extends ConcretePrereqObject {
  final CdomSingleRef<PCClass> _exchangeClass;
  final int _minDonatingLevel;
  final int _maxDonatedLevels;
  final int _donatingLowerLevelBound;

  LevelExchange(CdomSingleRef<PCClass> pcc, int minDonatingLvl, int maxDonated, int donatingLowerBound)
      : _exchangeClass = pcc,
        _minDonatingLevel = minDonatingLvl,
        _maxDonatedLevels = maxDonated,
        _donatingLowerLevelBound = donatingLowerBound {
    if (minDonatingLvl <= 0) {
      throw ArgumentError('Error: Min Donating Level <= 0: Cannot Allow Donations to produce negative levels');
    }
    if (maxDonated <= 0) {
      throw ArgumentError('Error: Max Donated Levels <= 0: Cannot Allow Donations to produce negative levels');
    }
    if (donatingLowerBound < 0) {
      throw ArgumentError('Error: Max Remaining Levels < 0: Cannot Allow Donations to produce negative levels');
    }
    if (minDonatingLvl - maxDonated > donatingLowerBound) {
      throw ArgumentError('Error: Donating Lower Bound cannot be reached');
    }
  }

  int getDonatingLowerLevelBound() => _donatingLowerLevelBound;
  CdomSingleRef<PCClass> getExchangeClass() => _exchangeClass;
  int getMaxDonatedLevels() => _maxDonatedLevels;
  int getMinDonatingLevel() => _minDonatingLevel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LevelExchange) return false;
    return _minDonatingLevel == other._minDonatingLevel &&
        _maxDonatedLevels == other._maxDonatedLevels &&
        _donatingLowerLevelBound == other._donatingLowerLevelBound &&
        _exchangeClass == other._exchangeClass;
  }

  @override
  int get hashCode => _minDonatingLevel * 23 + _maxDonatedLevels * 31 + _donatingLowerLevelBound;
}
