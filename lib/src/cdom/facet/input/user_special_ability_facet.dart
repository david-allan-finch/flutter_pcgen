//
// Copyright (c) Thomas Parker, 2012.
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
// Translation of pcgen.cdom.facet.input.UserSpecialAbilityFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/UserSpecialAbilityFacet.java

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

/// UserSpecialAbilityFacet tracks the SpecialAbility objects added to a Player
/// Character by explicit user action (old UI capability).
class UserSpecialAbilityFacet {
  dynamic trackingFacet; // PlayerCharacterTrackingFacet

  // AbstractQualifiedListFacet state
  final Map<CharID, Map<dynamic, Set<dynamic>>> _cache = {};

  /// Returns a non-null copy of the List of resolved SpecialAbility objects
  /// for the given source CDOMObject and the Player Character represented by
  /// the given CharID.
  List<dynamic> getResolved(CharID id, dynamic source) {
    List<dynamic> returnList = [];
    dynamic pc = trackingFacet?.getPC(id);
    // SAProcessor equivalent - process each qualifying SpecialAbility
    for (dynamic sa in getQualifiedSet(id, source)) {
      returnList.add(_processSpecialAbility(sa, source, pc));
    }
    return returnList;
  }

  /// Returns a non-null List of processed SpecialAbility objects for the
  /// Player Character represented by the given CharID.
  List<T> getAllResolved<T>(CharID id, dynamic qa) {
    return actOnQualifiedSet<T>(id, qa);
  }

  // Stub methods from AbstractQualifiedListFacet
  List<dynamic> getQualifiedSet(CharID id, dynamic source) => [];
  List<T> actOnQualifiedSet<T>(CharID id, dynamic qa) => [];
  dynamic _processSpecialAbility(dynamic sa, dynamic source, dynamic pc) => sa;
}
