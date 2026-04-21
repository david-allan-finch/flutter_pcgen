// Copyright (c) Thomas Parker, 2009-14.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

// stub: TotalSkillRankFacet, UsableSkillsFacet wiring
// stub: OutputDB.register("skills", this)
// stub: SkillRankChangeListener, AssociationChangeListener interfaces
// dynamic: Skill, SkillRankChangeEvent, AssociationChangeEvent (not yet translated)

/// SkillFacet tracks the Skills possessed by a Player Character.
class SkillFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {
  // @Autowired - stub
  dynamic totalSkillRankFacet;
  dynamic usableSkillsFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  /// Called when a skill rank changes (SkillRankChangeListener).
  void rankChanged(dynamic lce) {
    // stub: SkillRankChangeEvent
    final CharID id = lce.getCharID();
    final dynamic skill = lce.getSkill();
    if ((lce.getNewRank() as num) == 0.0) {
      remove(id, skill, lce.getSource());
    } else {
      add(id, skill, lce.getSource());
    }
  }

  /// Called when association (skill rank bonus) changes (AssociationChangeListener).
  void bonusChange(dynamic dfce) {
    // stub: AssociationChangeEvent
    final CharID id = dfce.getCharID();
    final dynamic sk = dfce.getSkill();
    final num ranks = dfce.getNewVal() as num;
    if (ranks.toDouble() > 0) {
      add(id, sk, dfce.getSource());
    } else {
      remove(id, sk, dfce.getSource());
    }
  }

  void setTotalSkillRankFacet(dynamic f) => totalSkillRankFacet = f;
  void setUsableSkillsFacet(dynamic f) => usableSkillsFacet = f;

  void init() {
    // stub: totalSkillRankFacet.addAssociationChangeListener(this)
    // stub: usableSkillsFacet.addDataFacetChangeListener(this)
    // stub: OutputDB.register("skills", this)
  }
}
