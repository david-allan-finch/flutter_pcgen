// Copyright (c) Thomas Parker, 2009-14.
//
// Translation of pcgen.cdom.facet.DirectAbilityInputFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import '../helper/cn_ability_selection.dart';
import 'base/abstract_single_source_list_facet.dart';

/// Tracks [CNAbilitySelection] objects granted via indirect %LIST grants.
class DirectAbilityInputFacet
    extends AbstractSingleSourceListFacet<CNAbilitySelection, CDOMObject> {
  void addSelection(CharID id, CDOMObject owner, CNAbilitySelection as) {
    add(id, as, owner);
  }

  void removeSelection(CharID id, CDOMObject owner, CNAbilitySelection as) {
    remove(id, as, owner);
  }
}
