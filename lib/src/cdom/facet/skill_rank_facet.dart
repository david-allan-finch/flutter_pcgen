// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.SkillRankFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'base/abstract_storage_facet.dart';

/// Stores per-class skill rank assignments for each Skill on a Player Character.
class SkillRankFacet extends AbstractStorageFacet<CharID> {
  final _support = SkillRankChangeSupport();

  void set(CharID id, Skill skill, PCClass pcc, double value) {
    final oldRank = getRank(id, skill);
    final map = _getConstructingInfo(id);
    (map[skill] ??= {})[pcc] = value;
    final newRank = getRank(id, skill);
    _support.fireSkillRankChangeEvent(id, skill, oldRank, newRank);
  }

  void remove(CharID id, Skill sk, PCClass pcc) {
    final map = _getInfo(id);
    if (map == null) return;
    final clMap = map[sk];
    if (clMap == null) return;
    final oldRank = getRank(id, sk);
    clMap.remove(pcc);
    final newRank = getRank(id, sk);
    _support.fireSkillRankChangeEvent(id, sk, oldRank, newRank);
  }

  double getRank(CharID id, Skill sk) {
    double rank = 0.0;
    final clMap = _getInfo(id)?[sk];
    if (clMap != null) {
      for (final d in clMap.values) {
        rank += d;
      }
    }
    return rank;
  }

  Iterable<PCClass> getClasses(CharID id, Skill sk) {
    return _getInfo(id)?[sk]?.keys ?? const [];
  }

  double? get(CharID id, Skill sk, PCClass pcc) {
    return _getInfo(id)?[sk]?[pcc];
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final map = _getInfo(source);
    if (map != null) {
      for (final entry in map.entries) {
        for (final clEntry in entry.value.entries) {
          set(copy, entry.key, clEntry.key, clEntry.value);
        }
      }
    }
  }

  void addSkillRankChangeListener(SkillRankChangeListener listener) {
    _support.addListener(listener);
  }

  Map<Skill, Map<PCClass, double>>? _getInfo(CharID id) =>
      getCache(id) as Map<Skill, Map<PCClass, double>>?;

  Map<Skill, Map<PCClass, double>> _getConstructingInfo(CharID id) {
    var map = _getInfo(id);
    if (map == null) {
      map = {};
      setCache(id, map);
    }
    return map;
  }
}

typedef SkillRankChangeListener = void Function(SkillRankChangeEvent event);

class SkillRankChangeEvent {
  final CharID charID;
  final Skill skill;
  final double oldRank;
  final double newRank;

  const SkillRankChangeEvent(
      this.charID, this.skill, this.oldRank, this.newRank);
}

class SkillRankChangeSupport {
  final List<SkillRankChangeListener> _listeners = [];

  void addListener(SkillRankChangeListener listener) {
    _listeners.add(listener);
  }

  void removeListener(SkillRankChangeListener listener) {
    _listeners.remove(listener);
  }

  void fireSkillRankChangeEvent(
      CharID id, Skill sk, double oldRank, double newRank) {
    if (oldRank == newRank) return;
    final event = SkillRankChangeEvent(id, sk, oldRank, newRank);
    for (int i = _listeners.length - 1; i >= 0; i--) {
      _listeners[i](event);
    }
  }
}
