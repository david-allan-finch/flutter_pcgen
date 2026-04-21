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
// Translation of pcgen.cdom.processor.ChangeArmorType
import 'package:flutter_pcgen/src/cdom/content/processor.dart';

// A Processor that remaps an armor type string to a different type.
class ChangeArmorType implements Processor<String> {
  final String _source;
  final String _result;

  ChangeArmorType(String sourceType, String resultType)
      : _source = sourceType,
        _result = resultType;

  @override
  String applyProcessor(String sourceType, Object? context) =>
      _source.toLowerCase() == sourceType.toLowerCase() ? _result : sourceType;

  @override
  Type getModifiedClass() => String;

  List<String> applyProcessorToList(Iterable<String> armorTypes) {
    final returnList = <String>[];
    for (final type in armorTypes) {
      final mod = applyProcessor(type, null);
      returnList.add(mod.toUpperCase());
    }
    return returnList;
  }

  @override
  String getLSTformat([bool useAny = false]) =>
      _result.isEmpty ? _source : '$_source|$_result';

  @override
  int get hashCode => 31 * _source.hashCode + _result.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is ChangeArmorType &&
      obj._source == _source &&
      obj._result == _result;
}
