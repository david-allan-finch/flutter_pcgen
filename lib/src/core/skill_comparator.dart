//
// Copyright 2003 (C) James Dempsey
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
// Translation of pcgen.core.SkillComparator
import 'package:flutter_pcgen/src/core/skill.dart';

// Sorts Skill objects by name or trained status, ascending or descending.
class SkillComparator implements Comparator<Skill> {
  static const int resortName = 0;
  static const int resortTrained = 1;
  static const bool resortAscending = true;
  static const bool resortDescending = false;

  final dynamic _pc; // PlayerCharacter
  final int _sort;
  final bool _sortOrder;

  SkillComparator(dynamic pc, int sort, bool sortOrder)
      : _pc = pc,
        _sort = sort,
        _sortOrder = sortOrder;

  @override
  int compare(Skill obj1, Skill obj2) {
    final Skill s1;
    final Skill s2;
    if (_sortOrder == resortAscending || _sort == resortTrained) {
      s1 = obj1;
      s2 = obj2;
    } else {
      s1 = obj2;
      s2 = obj1;
    }

    if (_sort == resortTrained) {
      // getTotalRank would come from SkillRankControl — approximate with 0
      final r1 = 0.0; // SkillRankControl.getTotalRank(_pc, s1)
      final r2 = 0.0; // SkillRankControl.getTotalRank(_pc, s2)
      if (r1 > 0.0 && r2 <= 0.0) return _sortOrder == resortAscending ? -1 : 1;
      if (r1 <= 0.0 && r2 > 0.0) return _sortOrder == resortAscending ? 1 : -1;
      return s1.getOutputName().toLowerCase().compareTo(s2.getOutputName().toLowerCase());
    }
    return s1.getOutputName().toLowerCase().compareTo(s2.getOutputName().toLowerCase());
  }
}

// Dart equivalent of Comparator functional interface.
abstract interface class Comparator<T> {
  int compare(T a, T b);
}
