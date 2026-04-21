//
// Copyright 2014 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.enumeration.FactKey
import '../../base/util/case_insensitive_map.dart';
import '../../base/util/format_manager.dart';

// Typesafe key for FACT storage in CDOMObject.
class FactKey<T> {
  static final CaseInsensitiveMap<FactKey<dynamic>> _typeMap = CaseInsensitiveMap();

  final String _fieldName;
  final FormatManager<T> formatManager;

  FactKey._(this._fieldName, this.formatManager);

  @override
  String toString() => _fieldName;

  T? cast(dynamic value) {
    if (value == null) return null;
    return value as T;
  }

  static FactKey<T> getConstant<T>(String name, FormatManager<T> fmtManager) {
    final existing = _typeMap[name];
    if (existing != null) return existing as FactKey<T>;
    final key = FactKey<T>._(name, fmtManager);
    _typeMap[name] = key;
    return key;
  }

  static FactKey<T> valueOf<T>(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined FactKey');
    return key as FactKey<T>;
  }

  static Iterable<FactKey<dynamic>> getAllConstants() =>
      List.unmodifiable(_typeMap.values());

  static void clearConstants() => _typeMap.clear();
}
