// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.PrerequisiteFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/qualifying_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'player_character_tracking_facet.dart';

/// A transition-class facet that tests prerequisites for a Player Character.
/// Delegates to [PlayerCharacterTrackingFacet] to get the PC and then calls
/// [QualifyingObject.qualifies].
class PrerequisiteFacet {
  late PlayerCharacterTrackingFacet trackingFacet;

  /// Returns true if the PC identified by [id] qualifies for [obj] when
  /// [obj] is sourced from [source].
  bool qualifies(CharID id, QualifyingObject obj, Object? source) {
    final pc = trackingFacet.getPC(id);
    final cdo = source is CDOMObject ? source : null;
    return obj.qualifies(pc, cdo);
  }
}
