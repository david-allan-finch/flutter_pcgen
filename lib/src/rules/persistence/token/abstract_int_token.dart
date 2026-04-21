//
// Copyright (c) 2009 Mark Jeffries <motorviper@users.sourceforge.net>
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
// Translation of pcgen.rules.persistence.token.AbstractIntToken

import '../../../cdom/base/cdom_object.dart';
import '../../../cdom/enumeration/integer_key.dart';
import '../../../rules/context/load_context.dart';
import 'abstract_token.dart';
import 'cdom_token.dart';
import 'cdom_write_token.dart';
import 'parse_result.dart';

/// Abstract base for tokens that store a single integer value on a CDOMObject.
///
/// Subclasses implement [getTokenName], [getIntegerKey], and optionally
/// [minValue] / [maxValue] to constrain the accepted range.
abstract class AbstractIntToken<T extends CDOMObject> extends AbstractToken
    implements CDOMToken<T>, CDOMWriteToken<T> {
  /// The IntegerKey used to store the parsed value.
  IntegerKey get integerKey;

  /// Minimum accepted value (inclusive). Override to add lower bound.
  int? get minValue => null;

  /// Maximum accepted value (inclusive). Override to add upper bound.
  int? get maxValue => null;

  @override
  ParseResult parseToken(LoadContext context, T obj, String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return ParseResultFail(
          '${getTokenName()} expected an integer. Tag must be of the form: '
          '${getTokenName()}:<int>');
    }
    final min = minValue;
    final max = maxValue;
    if (min != null && parsed < min) {
      return ParseResultFail('${getTokenName()} must be an integer >= $min');
    }
    if (max != null && parsed > max) {
      return ParseResultFail('${getTokenName()} must be an integer <= $max');
    }
    if (min != null && max != null && (parsed < min || parsed > max)) {
      return ParseResultFail(
          '${getTokenName()} must be an integer between $min and $max');
    }
    obj.put(integerKey, parsed);
    return ParseResult.success;
  }

  @override
  List<String>? unparse(LoadContext context, T obj) {
    final val = obj.get(integerKey);
    if (val == null) return null;
    return ['${getTokenName()}:$val'];
  }
}
