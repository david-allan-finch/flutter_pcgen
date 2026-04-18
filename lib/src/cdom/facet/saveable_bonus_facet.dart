// Copyright (c) Tom Parker, 2010.
//
// Translation of pcgen.cdom.facet.SaveableBonusFacet

import '../enumeration/char_id.dart';
import '../../core/bonus/bonus_obj.dart';
import 'base/abstract_sourced_list_facet.dart';

/// Tracks [BonusObj] objects that are "manually" applied to a Player Character
/// and need to be saved to the PCG file.
///
/// These are bonus objects granted as side effects of other behavior, not those
/// directly granted via BONUS: tokens in LST files.
class SaveableBonusFacet
    extends AbstractSourcedListFacet<CharID, BonusObj> {}
