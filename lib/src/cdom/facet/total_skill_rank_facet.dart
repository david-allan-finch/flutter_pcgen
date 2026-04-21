// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.TotalSkillRankFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_storage_facet.dart';
import 'bonus_skill_rank_change_facet.dart' as bsrc;
import 'skill_rank_facet.dart' as srf;

/// Stores total skill ranks (user ranks + BONUS:SKILLRANK) for a Player Character.
class TotalSkillRankFacet extends AbstractStorageFacet<CharID> {
  late srf.SkillRankFacet skillRankFacet;
  late bsrc.BonusSkillRankChangeFacet bonusSkillRankChangeFacet;

  final List<AssociationChangeListener> _listeners = [];

  void set(CharID id, Skill sk, double rank) {
    final map = _getConstructingInfo(id);
    final currentRank = map[sk];
    if (currentRank == null || rank != currentRank) {
      map[sk] = rank;
      for (final listener in _listeners) {
        listener(AssociationChangeEvent(id, sk, currentRank, rank));
      }
    }
  }

  void remove(CharID id, Skill sk) {
    final map = _getInfo(id);
    if (map == null) return;
    final currentRank = map[sk];
    if (currentRank == null) return;
    for (final listener in _listeners) {
      listener(AssociationChangeEvent(id, sk, currentRank, 0.0));
    }
  }

  double? get(CharID id, Skill sk) => _getInfo(id)?[sk];

  @override
  void copyContents(CharID source, CharID copy) {
    final map = _getInfo(source);
    if (map != null) {
      _getConstructingInfo(copy).addAll(map);
    }
  }

  void addAssociationChangeListener(AssociationChangeListener listener) {
    _listeners.add(listener);
  }

  void removeAssociationChangeListener(AssociationChangeListener listener) {
    _listeners.remove(listener);
  }

  Map<Skill, double>? _getInfo(CharID id) =>
      getCache(id) as Map<Skill, double>?;

  Map<Skill, double> _getConstructingInfo(CharID id) {
    var map = _getInfo(id);
    if (map == null) {
      map = {};
      setCache(id, map);
    }
    return map;
  }

  void _onBonusSkillRankChange(bsrc.SkillRankChangeEvent srce) {
    final id = srce.charID;
    final skill = srce.skill;
    final newBonus = srce.newVal;
    final rank = skillRankFacet.getRank(id, skill);
    set(id, skill, rank + newBonus);
  }

  void _onSkillRankChange(srf.SkillRankChangeEvent srce) {
    final id = srce.charID;
    final skill = srce.skill;
    final newRank = srce.newRank;
    final bonus = bonusSkillRankChangeFacet.getRank(id, skill);
    set(id, skill, newRank + bonus);
  }

  void init() {
    skillRankFacet.addSkillRankChangeListener(_onSkillRankChange);
    bonusSkillRankChangeFacet.addSkillRankChangeListener(_onBonusSkillRankChange);
  }
}

typedef AssociationChangeListener = void Function(AssociationChangeEvent event);

class AssociationChangeEvent {
  final CharID charID;
  final Skill skill;
  final double? oldVal;
  final double newVal;

  const AssociationChangeEvent(
      this.charID, this.skill, this.oldVal, this.newVal);
}
