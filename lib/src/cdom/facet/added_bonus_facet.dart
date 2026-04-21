// Copyright (c) Tom Parker, 2010.
//
// Translation of pcgen.cdom.facet.AddedBonusFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/bonus/bonus_obj.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';

/// Tracks [BonusObj] objects that are "manually" applied to a Player Character
/// as side effects (not directly granted via BONUS: tokens in LST files).
class AddedBonusFacet
    extends AbstractSourcedListFacet<CharID, BonusObj> {}
