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
// Translation of pcgen.rules.persistence.token.AbstractToken

import 'parse_result.dart';

/// Base class for all token implementations, providing common parsing utilities.
///
/// Subclasses implement [getTokenName] to return the LST keyword (e.g. "TYPE",
/// "BONUS", "SOURCEPAGE"). Concrete token classes typically also implement
/// CDOMToken<T> or CDOMPrimaryToken<T>.
abstract class AbstractToken {
  /// Returns the LST keyword handled by this token (e.g. "TYPE", "SOURCEPAGE").
  String getTokenName();

  // ---------------------------------------------------------------------------
  // Separator validation helpers (ported from Java AbstractToken)
  // ---------------------------------------------------------------------------

  /// Validates that [value] is not null or empty.
  ParseResult? checkForIllegalNull(String? value) {
    if (value == null) {
      return ParseResultFail('${getTokenName()} may not have null argument');
    }
    return null;
  }

  /// Validates that [value] is not empty.
  ParseResult? checkForIllegalEmpty(String value, String separator) {
    if (value.isEmpty) {
      return ParseResultFail('${getTokenName()} may not have empty argument');
    }
    return null;
  }

  /// Validates that [value] does not start with [separator].
  ParseResult? checkForIllegalSeparatorStart(String separator, String value) {
    if (value.startsWith(separator)) {
      return ParseResultFail(
          '${getTokenName()} arguments may not start with $separator : $value');
    }
    return null;
  }

  /// Validates that [value] does not end with [separator].
  ParseResult? checkForIllegalSeparatorEnd(String separator, String value) {
    if (value.endsWith(separator)) {
      return ParseResultFail(
          '${getTokenName()} arguments may not end with $separator : $value');
    }
    return null;
  }

  /// Validates that [value] does not contain a doubled separator.
  ParseResult? checkForIllegalDoubleSeparator(String separator, String value) {
    if (value.contains('$separator$separator')) {
      return ParseResultFail(
          '${getTokenName()} arguments uses double separator $separator$separator : $value');
    }
    return null;
  }

  /// Checks that [value] does not start with, end with, or double [separator].
  ///
  /// Mirrors Java's AbstractToken.checkForIllegalSeparator(char, String).
  ParseResult checkForIllegalSeparator(String separator, String value) {
    if (value.startsWith(separator)) {
      return ParseResultFail(
          '${getTokenName()} arguments may not start with $separator : $value');
    }
    if (value.endsWith(separator)) {
      return ParseResultFail(
          '${getTokenName()} arguments may not end with $separator : $value');
    }
    if (value.contains('$separator$separator')) {
      return ParseResultFail(
          '${getTokenName()} arguments uses double separator '
          '$separator$separator : $value');
    }
    return ParseResult.success;
  }

  /// Checks that [value] is non-empty and separators are used correctly.
  ///
  /// Mirrors Java's AbstractToken.checkSeparatorsAndNonEmpty(char, String).
  ParseResult checkSeparatorsAndNonEmpty(String separator, String value) {
    if (value.isEmpty) {
      return ParseResultFail(
          '${getTokenName()} may not have empty argument');
    }
    return checkForIllegalSeparator(separator, value);
  }
}
