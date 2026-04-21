// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.BonusSkillRankChangeFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'base/abstract_storage_facet.dart';
import 'bonus_checking_facet.dart';

/// Tracks SKILLRANK bonus changes and fires [SkillRankChangeEvent]s.
class BonusSkillRankChangeFacet extends AbstractStorageFacet<CharID> {
  final _support = SkillRankChangeSupport();
  late BonusCheckingFacet bonusCheckingFacet;

  /// Checks current SKILLRANK bonuses against cached values; fires on change.
  void reset(CharID id, Iterable<Skill> allSkills) {
    final map = _getConstructingInfo(id);
    for (final s in allSkills) {
      double newValue =
          bonusCheckingFacet.getBonus(id, 'SKILLRANK', s.getKeyName());
      for (final singleType in s.getTrueTypeList(false)) {
        newValue +=
            bonusCheckingFacet.getBonus(id, 'SKILLRANK', 'TYPE.$singleType');
      }
      final oldValue = map[s];
      if (oldValue == null || newValue != oldValue) {
        map[s] = newValue;
        _support.fireSkillRankChange(id, s, oldValue, newValue);
      }
    }
  }

  double getRank(CharID id, Skill skill) {
    return _getInfo(id)?[skill] ?? 0.0;
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final map = _getInfo(source);
    if (map != null) {
      _getConstructingInfo(copy).addAll(map);
    }
  }

  void addSkillRankChangeListener(SkillRankChangeListener listener) {
    _support.addSkillRankChangeListener(listener);
  }

  void removeSkillRankChangeListener(SkillRankChangeListener listener) {
    _support.removeSkillRankChangeListener(listener);
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
}

typedef SkillRankChangeListener = void Function(SkillRankChangeEvent srce);

class SkillRankChangeEvent {
  final CharID charID;
  final Skill skill;
  final double? oldVal;
  final double newVal;

  const SkillRankChangeEvent(this.charID, this.skill, this.oldVal, this.newVal);
}

class SkillRankChangeSupport {
  final List<SkillRankChangeListener> _listeners = [];

  void addSkillRankChangeListener(SkillRankChangeListener listener) {
    _listeners.add(listener);
  }

  void removeSkillRankChangeListener(SkillRankChangeListener listener) {
    _listeners.remove(listener);
  }

  void fireSkillRankChange(
      CharID id, Skill skill, double? oldValue, double newValue) {
    final event = SkillRankChangeEvent(id, skill, oldValue, newValue);
    for (final target in _listeners) {
      target(event);
    }
  }
}
