//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.core.character.WieldCategory
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';

// Defines how a weapon is wielded (e.g. Light, One-Handed, Two-Handed, Too Large).
final class WieldCategory implements Loadable {
  String? _sourceURI;
  String? _categoryName;
  int handsRequired = 0;
  bool isFinessable = false;
  int sizeDifference = 0;

  final Map<int, CDOMSingleRef<WieldCategory>> _wcSteps = {};
  final List<_QualifiedWieldSwitch> _categorySwitches = [];

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  String getKeyName() => _categoryName ?? '';

  @override
  String? getDisplayName() => _categoryName;

  @override
  void setName(String name) { _categoryName = name; }

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void setWieldCategoryStep(int location, CDOMSingleRef<WieldCategory> stepCat) {
    _wcSteps[location] = stepCat;
  }

  WieldCategory? getWieldCategoryStep(int steps) {
    final ref = _wcSteps[steps];
    return ref?.get();
  }

  void addCategorySwitch(_QualifiedWieldSwitch qo) {
    _categorySwitches.add(qo);
  }

  int getObjectSizeInt(Equipment eq) => eq.sizeInt() + sizeDifference;

  WieldCategory adjustForSize(PlayerCharacter pc, Equipment eq) {
    // Simplified — full implementation requires bonus system integration
    return _getSwitch(pc, eq);
  }

  WieldCategory _getSwitch(PlayerCharacter pc, Equipment eq) {
    WieldCategory pcWCat = this;
    for (final qo in _categorySwitches) {
      if (qo.passes(pc, eq)) {
        pcWCat = qo.category.get();
      }
    }
    return pcWCat;
  }

  @override
  int get hashCode => (_categoryName ?? '').hashCode;

  @override
  bool operator ==(Object o) =>
      o is WieldCategory && _categoryName == o._categoryName;
}

class _QualifiedWieldSwitch {
  final CDOMSingleRef<WieldCategory> category;
  _QualifiedWieldSwitch(this.category);
  bool passes(PlayerCharacter pc, Equipment eq) => true; // prereq check stub
}
