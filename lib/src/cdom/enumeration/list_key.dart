//
// Copyright 2005 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.ListKey
import 'package:flutter_pcgen/src/base/util/case_insensitive_map.dart';

// Typesafe key for list storage in CDOMObject.
class ListKey<T> {
  static final CaseInsensitiveMap<ListKey<dynamic>> _typeMap = CaseInsensitiveMap();

  // Commonly used named constants.
  static final ListKey<dynamic> add = getConstant<dynamic>('ADD');
  static final ListKey<dynamic> allow = getConstant<dynamic>('ALLOW');
  static final ListKey<dynamic> appliedRace = getConstant<dynamic>('APPLIED_RACE');
  static final ListKey<dynamic> benefit = getConstant<dynamic>('BENEFIT');
  static final ListKey<dynamic> bonus = getConstant<dynamic>('BONUS');
  static final ListKey<dynamic> cast = getConstant<dynamic>('CAST');
  static final ListKey<dynamic> domain = getConstant<dynamic>('DOMAIN');
  static final ListKey<dynamic> eqMod = getConstant<dynamic>('EQMOD');
  static final ListKey<dynamic> eqModInfo = getConstant<dynamic>('EQMOD_INFO');
  static final ListKey<dynamic> kitChoice = getConstant<dynamic>('KIT_CHOICE');
  static final ListKey<dynamic> known = getConstant<dynamic>('KNOWN');
  static final ListKey<dynamic> knownSpells = getConstant<dynamic>('KNOWN_SPELLS');
  static final ListKey<dynamic> remove = getConstant<dynamic>('REMOVE');
  static final ListKey<dynamic> removedFactKey = getConstant<dynamic>('REMOVED_FACTKEY');
  static final ListKey<dynamic> removedFactSetKey = getConstant<dynamic>('REMOVED_FACTSETKEY');
  static final ListKey<dynamic> removedIntegerKey = getConstant<dynamic>('REMOVED_INTEGERKEY');
  static final ListKey<dynamic> removedObjectKey = getConstant<dynamic>('REMOVED_OBJECTKEY');
  static final ListKey<dynamic> removedStringKey = getConstant<dynamic>('REMOVED_STRINGKEY');
  static final ListKey<dynamic> specialtyKnown = getConstant<dynamic>('SPECIALTY_KNOWN');
  static final ListKey<dynamic> type = getConstant<dynamic>('TYPE');

  final String _fieldName;
  final Type elementType;

  ListKey._(this._fieldName, this.elementType);

  @override
  String toString() => _fieldName;

  static ListKey<T> getConstant<T>(String name) {
    final existing = _typeMap[name];
    if (existing != null) return existing as ListKey<T>;
    final key = ListKey<T>._(name, T);
    _typeMap[name] = key;
    return key;
  }

  static ListKey<T> valueOf<T>(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined ListKey');
    return key as ListKey<T>;
  }

  static Iterable<ListKey<dynamic>> getAllConstants() =>
      List.unmodifiable(_typeMap.values());

  static void clearConstants() => _typeMap.clear();
}
