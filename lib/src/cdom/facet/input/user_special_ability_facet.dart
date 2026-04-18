// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/UserSpecialAbilityFacet.java

import '../../../enumeration/char_id.dart';

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
