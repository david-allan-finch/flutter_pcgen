//
// Copyright 2002 (C) Thomas Behr <ravenlock@gmx.de>
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
// Translation of pcgen.system.LanguageBundle

/// Provides localised strings from resource bundles.
final class LanguageBundle {
  static final Map<String, String> _bundle = {};

  LanguageBundle._();

  static void setBundle(Map<String, String> bundle) =>
      _bundle
        ..clear()
        ..addAll(bundle);

  static String getString(String key, [List<Object>? args]) {
    String? value = _bundle[key];
    if (value == null) return '[$key not defined]';
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        value = value!.replaceAll('{$i}', args[i].toString());
      }
    }
    return value!;
  }

  static int getMnemonic(String key, [String defaultChar = '']) {
    final s = _bundle[key];
    if (s == null || s.isEmpty) {
      return defaultChar.isEmpty ? 0 : defaultChar.codeUnitAt(0);
    }
    return s.codeUnitAt(0);
  }
}
