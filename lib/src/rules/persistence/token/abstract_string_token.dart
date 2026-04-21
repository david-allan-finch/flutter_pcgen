//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.rules.persistence.token.AbstractStringToken

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'abstract_non_empty_token.dart';
import 'cdom_write_token.dart';
import 'parse_result.dart';

/// Abstract base for tokens that store a single String value on a CDOMObject.
///
/// Subclasses implement [getTokenName] and [stringKey] to indicate which
/// StringKey holds the value.
abstract class AbstractStringToken<T extends CDOMObject>
    extends AbstractNonEmptyToken<T> implements CDOMWriteToken<T> {
  /// The StringKey used to store the parsed string.
  StringKey get stringKey;

  @override
  ParseResult parseNonEmptyToken(LoadContext context, T obj, String value) {
    obj.put(stringKey, value);
    return ParseResult.success;
  }

  @override
  List<String>? unparse(LoadContext context, T obj) {
    final val = obj.get(stringKey) as String?;
    if (val == null || val.isEmpty) return null;
    return ['${getTokenName()}:$val'];
  }
}
