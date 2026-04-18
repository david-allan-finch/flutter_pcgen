// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.VariableCheckingFacet

import '../enumeration/char_id.dart';
import 'player_character_tracking_facet.dart';

/// A transition-class facet that retrieves variable values from a Player
/// Character. Delegates to [PlayerCharacterTrackingFacet].
class VariableCheckingFacet {
  late PlayerCharacterTrackingFacet trackingFacet;

  num getVariableValue(CharID id, String variable, [String context = '']) {
    final pc = trackingFacet.getPC(id);
    return pc.getVariableValue(variable, context);
  }
}
