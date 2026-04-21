// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.DefaultClassSkillListFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/list/class_skill_list.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'base/abstract_scope_facet.dart';
import 'model/skill_list_facet.dart';

/// Stores the default [ClassSkillList] for each [PCClass] on a Player
/// Character, notifying [SkillListFacet] when the scope changes.
class DefaultClassSkillListFacet
    extends AbstractScopeFacet<CharID, PCClass, ClassSkillList> {
  late SkillListFacet skillListFacet;

  void init() {
    addScopeFacetChangeListener(skillListFacet);
  }
}
