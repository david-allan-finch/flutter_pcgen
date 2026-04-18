// Copyright (c) Tom Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.ArmorClassFacet

import '../../enumeration/char_id.dart';
import '../prerequisite_facet.dart';
import '../player_character_tracking_facet.dart';

/// Calculates the Armor Class (types of armor class) of a Player Character.
/// AC types are defined in the game mode; none are hardcoded here.
class ArmorClassFacet {
  late PrerequisiteFacet prerequisiteFacet;
  late PlayerCharacterTrackingFacet trackingFacet;

  /// Calculates the Armor Class of a certain type.
  @Deprecated('Use bonus system directly')
  int calcACOfType(CharID id, String type) {
    // TODO: Requires game mode ACType add/remove lists and BonusToken lookup.
    // SettingsHandler.getGame().getACTypeAddString(type) / getACTypeRemoveString(type)
    return 0;
  }
}
