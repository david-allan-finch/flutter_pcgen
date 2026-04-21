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
// Translation of pcgen.rules.persistence.token.AbstractNonEmptyToken

import '../../../rules/context/load_context.dart';
import 'abstract_token.dart';
import 'cdom_token.dart';
import 'parse_result.dart';

/// Abstract base for tokens that reject empty values.
///
/// Implements [CDOMToken.parseToken] to first check for null/empty values,
/// then delegates to [parseNonEmptyToken] which subclasses must implement.
abstract class AbstractNonEmptyToken<T> extends AbstractToken
    implements CDOMToken<T> {
  @override
  ParseResult parseToken(LoadContext context, T obj, String value) {
    if (value.isEmpty) {
      return ParseResultFail(
          '${getTokenName()} received an empty value, this is not allowed');
    }
    return parseNonEmptyToken(context, obj, value);
  }

  /// Called by [parseToken] after verifying [value] is not empty.
  ParseResult parseNonEmptyToken(LoadContext context, T obj, String value);
}
