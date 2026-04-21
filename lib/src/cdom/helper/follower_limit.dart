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
// Translation of pcgen.cdom.helper.FollowerLimit
import 'package:flutter_pcgen/src/base/formula/formula.dart';
import 'package:flutter_pcgen/src/cdom/list/companion_list.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';

// Represents an upper bound (as a Formula) on companions in a CompanionList.
class FollowerLimit {
  final CdomSingleRef<CompanionList> _ref;
  final Formula _formula;

  FollowerLimit(CdomSingleRef<CompanionList> clRef, Formula limit)
      : _ref = clRef,
        _formula = limit;

  CdomSingleRef<CompanionList> getCompanionList() => _ref;
  Formula getValue() => _formula;

  @override
  bool operator ==(Object other) {
    if (other is FollowerLimit) {
      return _ref == other._ref && _formula == other._formula;
    }
    return false;
  }

  @override
  int get hashCode => _ref.hashCode * 31 + _formula.hashCode;
}
