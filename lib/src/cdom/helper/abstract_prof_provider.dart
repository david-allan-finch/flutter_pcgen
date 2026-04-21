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
// Translation of pcgen.cdom.helper.AbstractProfProvider
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/constants.dart';
import 'package:flutter_pcgen/src/cdom/helper/prof_provider.dart';

// An AbstractProfProvider holds proficiency references either as direct
// objects or as Equipment TYPE references. Subclasses specify the proficiency
// kind (e.g. ARMOR, SHIELD).
abstract class AbstractProfProvider<T extends CDOMObject>
    extends ConcretePrereqObject
    implements ProfProvider<T> {
  // Direct proficiency references.
  final List<CDOMReference<T>> _direct;

  // Equipment TYPE references used to grant proficiency by type.
  final List<CDOMReference<dynamic>> _byEquipType;

  AbstractProfProvider(
    List<CDOMReference<T>> profs,
    List<CDOMReference<dynamic>> equipTypes,
  )   : _direct = List.of(profs),
        _byEquipType = List.of(equipTypes);

  // Subclasses must implement this to test type-based proficiency for an item.
  @override
  bool providesProficiencyFor(dynamic equipment);

  // Returns true if any direct reference contains the given proficiency.
  @override
  bool providesProficiency(T proficiency) {
    for (final ref in _direct) {
      if (ref.contains(proficiency)) {
        return true;
      }
    }
    return false;
  }

  // Returns true if any equipment-type reference matches all tokens of
  // the given dot-separated type string.
  @override
  bool providesEquipmentType(String typeString) {
    if (typeString.isEmpty) return false;
    // Build a case-insensitive set of the incoming type tokens.
    final types = <String>{};
    for (final t in typeString.split('.')) {
      types.add(t.toLowerCase());
    }
    outer:
    for (final ref in _byEquipType) {
      final lstFmt = ref.getLSTformat(false);
      if (!lstFmt.startsWith('TYPE=')) continue;
      final tokens = lstFmt.substring(5).split('.');
      for (final tok in tokens) {
        if (!types.contains(tok.toLowerCase())) {
          continue outer;
        }
      }
      return true;
    }
    return false;
  }

  // Subclasses return their sub-type string (e.g. "ARMOR", "SHIELD").
  String getSubType();

  // Returns the LST representation of this provider.
  @override
  String getLstFormat() {
    final sb = StringBuffer();
    final typeEmpty = _byEquipType.isEmpty;
    if (_direct.isNotEmpty) {
      sb.write(_joinLstFormat(_direct, Constants.pipe));
      if (!typeEmpty) {
        sb.write(Constants.pipe);
      }
    }
    if (!typeEmpty) {
      bool needPipe = false;
      final subType = getSubType();
      final dot = Constants.dot;
      for (final ref in _byEquipType) {
        if (needPipe) sb.write(Constants.pipe);
        needPipe = true;
        final lstFormat = ref.getLSTformat(false);
        if (lstFormat.startsWith('TYPE=')) {
          sb.write(subType);
          sb.write('TYPE=');
          final tokens = lstFormat.substring(5).split(dot);
          bool needDot = false;
          for (final tok in tokens) {
            if (tok != subType) {
              if (needDot) sb.write(dot);
              needDot = true;
              sb.write(tok);
            }
          }
        }
      }
    }
    return sb.toString();
  }

  // Joins a collection of references into a pipe-separated LST string.
  static String _joinLstFormat(
      List<CDOMReference<dynamic>> refs, String separator) {
    return refs.map((r) => r.getLSTformat(false)).join(separator);
  }

  @override
  bool operator ==(Object obj) {
    if (obj is AbstractProfProvider) {
      if (obj.getSubType() != getSubType()) return false;
      if (_direct != obj._direct) return false;
      if (_byEquipType != obj._byEquipType) return false;
      return equalsPrereqObject(obj);
    }
    return false;
  }

  @override
  int get hashCode =>
      _direct.fold(0, (h, r) => h ^ r.hashCode) * 29 +
      _byEquipType.fold(0, (h, r) => h ^ r.hashCode);
}
