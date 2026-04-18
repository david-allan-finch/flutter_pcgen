// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/XPFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_item_facet.dart';

/// XPFacet is a facet that tracks the Experience Points of a Player Character.
///
/// Earned Experience Points are Experience Points that the Player Character has
/// earned through play.
///
/// Level-Adjusted Experience Points are Experience Points that the Player
/// Character has received through level adjustments, and are independent of
/// earned Experience Points.
///
/// Total Experience Points are a combination of Earned Experience Points and
/// Level-Adjusted Experience Points.
class XPFacet extends AbstractItemFacet<CharID, int> {}
