//
// Copyright (c) Thomas Parker, 2009.
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
// Translation of pcgen.cdom.facet.fact.FactFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/FactFacet.java

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

/// FactFacet stores basic String information about a Player Character.
class FactFacet {
  final Map<CharID, Map<dynamic, String>> _cache = {};

  Map<dynamic, String> _getConstructingInfo(CharID id) {
    return _cache.putIfAbsent(id, () => {});
  }

  Map<dynamic, String>? _getInfo(CharID id) {
    return _cache[id];
  }

  /// Sets a String to be contained in the FactFacet for the given PCStringKey
  /// and Player Character identified by the given CharID.
  void set(CharID id, dynamic key, String s) {
    _getConstructingInfo(id)[key] = s;
  }

  /// Returns a String contained in the FactFacet for the given PCStringKey and
  /// Player Character identified by the given CharID.
  String? get(CharID id, dynamic key) {
    Map<dynamic, String>? rci = _getInfo(id);
    if (rci != null) {
      return rci[key];
    }
    return null;
  }

  /// Copies the contents of the FactFacet from one Player Character to another.
  void copyContents(CharID source, CharID destination) {
    Map<dynamic, String>? sourceRCI = _getInfo(source);
    if (sourceRCI != null) {
      _getConstructingInfo(destination).addAll(sourceRCI);
    }
  }
}
