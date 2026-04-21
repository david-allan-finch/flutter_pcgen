//
// Copyright 2003 (C) PCGen team
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
// Translation of pcgen.persistence.lst.LstUtils
// Utility class assisting with LST file parsing.
class LstUtils {
  LstUtils._(); // utility class

  static const String pipe = '|';
  static const String comma = ',';

  /// Split [token] at the first ':' into [tag, value].
  /// Returns [token, ''] if no ':' found.
  static (String tag, String value) splitToken(String token) {
    final colonIdx = token.indexOf(':');
    if (colonIdx == -1) return (token, '');
    return (token.substring(0, colonIdx), token.substring(colonIdx + 1));
  }

  /// Returns true if [tokenName] starts with 'PRE' or '!PRE'.
  static bool isPrereqToken(String tokenName) =>
      tokenName.startsWith('PRE') || tokenName.startsWith('!PRE');

  /// Returns true if [value] starts with 'BONUS'.
  static bool isBonusToken(String value) => value.startsWith('BONUS');
}
