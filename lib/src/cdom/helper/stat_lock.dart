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
// Translation of pcgen.cdom.helper.StatLock
import 'package:flutter_pcgen/src/base/formula/formula.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';

// Represents a PCStat locked to a specific value (which may be a formula).
class StatLock {
  final CDOMSingleRef<PCStat> _lockedStat;
  final Formula _lockValue;

  StatLock(CDOMSingleRef<PCStat> stat, Formula formula)
      : _lockedStat = stat,
        _lockValue = formula;

  PCStat getLockedStat() => _lockedStat.get();
  String getLSTformat() => _lockedStat.getLSTformat(false);
  Formula getLockValue() => _lockValue;

  @override
  bool operator ==(Object other) {
    if (other is StatLock) {
      return _lockValue == other._lockValue && _lockedStat == other._lockedStat;
    }
    return false;
  }

  @override
  int get hashCode => _lockValue.hashCode;
}
