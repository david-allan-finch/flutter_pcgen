//
// Copyright 2016 (C) Thomas Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.persistence.token.AbstractStringStoringToken

import '../../../cdom/base/cdom_object.dart';
import '../../../rules/context/load_context.dart';
import 'abstract_token.dart';
import 'cdom_token.dart';
import 'cdom_write_token.dart';
import 'parse_result.dart';

/// Abstract base for tokens that store a free-form string in a CDOMObject's
/// fact map (not the structured StringKey map).
///
/// Used for tokens like SOURCEPAGE, SOURCELONG, etc., that write to the
/// FactKey-based storage rather than the typed StringKey map.
abstract class AbstractStringStoringToken<T extends CDOMObject>
    extends AbstractToken implements CDOMToken<T>, CDOMWriteToken<T> {
  @override
  ParseResult parseToken(LoadContext context, T obj, String value) {
    if (value.isEmpty) {
      return ParseResultFail(
          '${getTokenName()} may not have an empty value');
    }
    storeString(obj, value);
    return ParseResult.success;
  }

  /// Stores [value] into [obj] using the token-specific storage mechanism.
  void storeString(T obj, String value);

  @override
  List<String>? unparse(LoadContext context, T obj) {
    final val = retrieveString(obj);
    if (val == null || val.isEmpty) return null;
    return ['${getTokenName()}:$val'];
  }

  /// Retrieves the previously stored string from [obj], or null if absent.
  String? retrieveString(T obj);
}
