// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.KitFacet

import '../enumeration/char_id.dart';
import '../../core/kit.dart';
import 'base/abstract_list_facet.dart';

/// Tracks [Kit] objects possessed by a Player Character.
class KitFacet extends AbstractListFacet<CharID, Kit> {
  // init() would register with OutputDB — omitted (output layer not yet translated).
}
