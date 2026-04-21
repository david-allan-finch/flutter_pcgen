// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.FormulaResolvingFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/base/formula/formula.dart';
import 'player_character_tracking_facet.dart';

/// A transition-class facet that resolves [Formula] values for a Player
/// Character. Delegates to [PlayerCharacterTrackingFacet].
class FormulaResolvingFacet {
  late PlayerCharacterTrackingFacet trackingFacet;

  num resolve(CharID id, Formula f, String source) {
    return f.resolve(trackingFacet.getPC(id), source);
  }
}
