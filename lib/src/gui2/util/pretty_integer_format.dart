//
// Copyright 2013 (C) Vincent Lhote
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
// Translation of pcgen.gui2.util.PrettyIntegerFormat

/// Formats small integers (e.g. ability modifiers) with a leading "+" for
/// positive values and the proper Unicode minus sign (U+2212) for negatives.
/// Values outside ±999 may not render symmetrically due to digit-width variance.
class PrettyIntegerFormat {
  PrettyIntegerFormat._();

  static final PrettyIntegerFormat _instance = PrettyIntegerFormat._();

  /// Returns the singleton formatter instance.
  static PrettyIntegerFormat getFormat() => _instance;

  /// Formats [value] as a signed integer string using "+" and "−".
  String format(int value) {
    if (value >= 0) {
      return '+$value';
    } else {
      // Replace the ASCII hyphen-minus with the proper Unicode minus sign.
      return '\u2212${value.abs()}';
    }
  }

  /// Parses a previously formatted string back to an [int], or returns null.
  int? parse(String text) {
    final cleaned = text
        .replaceAll('\u2212', '-')
        .replaceAll('+', '');
    return int.tryParse(cleaned);
  }
}
