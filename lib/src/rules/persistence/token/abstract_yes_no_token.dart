//
// Copyright 2014 (C) Thomas Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.persistence.token.AbstractYesNoToken

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'abstract_non_empty_token.dart';
import 'cdom_write_token.dart';
import 'parse_result.dart';

/// Abstract base for tokens that store a YES/NO boolean value on a CDOMObject.
///
/// Subclasses implement [getTokenName] and [objectKey] to indicate which
/// ObjectKey<bool> holds the value.
abstract class AbstractYesNoToken<T extends CDOMObject>
    extends AbstractNonEmptyToken<T> implements CDOMWriteToken<T> {
  /// The ObjectKey<bool> used to store the parsed value.
  ObjectKey get objectKey;

  @override
  ParseResult parseNonEmptyToken(LoadContext context, T obj, String value) {
    return parseYesNoToObjectKey(context, obj, value, getTokenName(), objectKey);
  }

  /// Parses a YES/NO token and stores the result in [objectKey] on [obj].
  static ParseResult parseYesNoToObjectKey(
      LoadContext context, CDOMObject obj, String value,
      String tokenName, ObjectKey key) {
    if (value.equalsIgnoreCase('YES') || value == 'Y' || value == '1') {
      obj.put(key, true);
    } else if (value.equalsIgnoreCase('NO') || value == 'N' || value == '0') {
      obj.put(key, false);
    } else {
      return ParseResultFail(
          '$tokenName expected YES or NO as a value, got: $value');
    }
    return ParseResult.success;
  }

  @override
  List<String>? unparse(LoadContext context, T obj) {
    final val = obj.getSafe(objectKey) as bool?;
    if (val == null) return null;
    return ['${getTokenName()}:${val ? 'YES' : 'NO'}'];
  }
}

extension _StringCI on String {
  bool equalsIgnoreCase(String other) =>
      toLowerCase() == other.toLowerCase();
}
