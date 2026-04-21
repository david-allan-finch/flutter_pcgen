//
// Copyright (c) 2008 Tom Parker <thpr@users.sourceforge.net>
//
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
// Translation of pcgen.cdom.helper.WeaponProfProvider
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/constants.dart';
import 'package:flutter_pcgen/src/cdom/base/qualifying_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_group_ref.dart';
import 'package:flutter_pcgen/src/core/weapon_prof.dart';

// A WeaponProfProvider stores weapon proficiency grants either as direct
// WeaponProf references, TYPE-based group references, or an ALL reference.
// It mirrors the AUTO:WEAPONPROF token storage with full CHANGEPROF awareness.
class WeaponProfProvider extends ConcretePrereqObject implements QualifyingObject {
  // Direct individual WeaponProf references.
  List<CDOMSingleRef<WeaponProf>>? _direct;

  // TYPE-based WeaponProf group references.
  List<CDOMGroupRef<WeaponProf>>? _type;

  // The ALL reference, if present.
  CDOMGroupRef<WeaponProf>? _all;

  // Adds a direct WeaponProf reference to this provider.
  void addWeaponProf(CDOMSingleRef<WeaponProf> ref) {
    _direct ??= [];
    _direct!.add(ref);
  }

  // Adds a TYPE-based WeaponProf group reference to this provider.
  void addWeaponProfType(CDOMGroupRef<WeaponProf> ref) {
    _type ??= [];
    _type!.add(ref);
  }

  // Sets the ALL reference for this provider.
  void addWeaponProfAll(CDOMGroupRef<WeaponProf> ref) {
    _all = ref;
  }

  // Returns all WeaponProf objects that this provider contains for the given
  // character, accounting for any CHANGEPROF adjustments.
  List<WeaponProf> getContainedProficiencies(CharID id) {
    final list = <WeaponProf>[];
    if (_all == null) {
      if (_direct != null) {
        for (final ref in _direct!) {
          list.add(ref.get());
        }
      }
      if (_type != null) {
        for (final ref in _type!) {
          list.addAll(getWeaponProfsInTarget(id, ref));
        }
      }
    } else {
      list.addAll(_all!.getContainedObjects());
    }
    return list;
  }

  // Returns the LST format of this provider.
  String getLstFormat() {
    if (_all != null) {
      return Constants.lstAll;
    }
    final sb = StringBuffer();
    final typeEmpty = _type == null || _type!.isEmpty;
    if (_direct != null && _direct!.isNotEmpty) {
      sb.write(_direct!.map((r) => r.getLSTformat(false)).join(Constants.pipe));
      if (!typeEmpty) {
        sb.write(Constants.pipe);
      }
    }
    if (!typeEmpty) {
      sb.write(_type!.map((r) => r.getLSTformat(false)).join(Constants.pipe));
    }
    return sb.toString();
  }

  @override
  bool operator ==(Object obj) {
    if (obj is WeaponProfProvider) {
      if (_direct == null) {
        if (obj._direct != null) return false;
      } else {
        if (_direct != obj._direct) return false;
      }
      if (_type == null) {
        if (obj._type != null) return false;
      } else {
        if (_type != obj._type) return false;
      }
      if (_all == null) {
        if (obj._all != null) return false;
      } else {
        if (_all != obj._all) return false;
      }
      return equalsPrereqObject(obj);
    }
    return false;
  }

  @override
  int get hashCode =>
      (_direct == null ? 0 : _direct.hashCode * 29) +
      (_type == null ? 0 : _type.hashCode);

  // Returns true if this provider contains no references at all.
  bool isEmpty() {
    return _all == null &&
        (_direct == null || _direct!.isEmpty) &&
        (_type == null || _type!.isEmpty);
  }

  // Returns true if the provider is valid: it must contain either an ALL
  // reference XOR at least one direct or type reference.
  bool isValid() {
    final hasDirect = _direct != null && _direct!.isNotEmpty;
    final hasType = _type != null && _type!.isNotEmpty;
    final hasIndividual = hasDirect || hasType;
    final hasAll = _all != null;
    return hasAll ^ hasIndividual;
  }

  // Returns the WeaponProfs contained in the given group reference for the
  // given character, respecting CHANGEPROF adjustments.
  // The facet lookup is deferred; subclasses or integration code may override.
  List<WeaponProf> getWeaponProfsInTarget(
      CharID id, CDOMGroupRef<WeaponProf> master) {
    // Stub: full CHANGEPROF facet lookup deferred to integration layer.
    return master.getContainedObjects();
  }
}
