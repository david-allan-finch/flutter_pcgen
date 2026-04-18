// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.LevelFacet

import '../../enumeration/char_id.dart';
import '../base/abstract_storage_facet.dart';
import '../model/class_facet.dart';

/// Stores level information (monster vs non-monster levels) for a PC.
/// Also fires [LevelChangeEvent]s when the total level changes.
class LevelFacet extends AbstractStorageFacet<CharID>
    implements ClassLevelChangeListener {
  final _support = LevelChangeSupport();

  int getNonMonsterLevelCount(CharID id) => _getInfo(id)?.nonMonsterLevels ?? 0;
  int getMonsterLevelCount(CharID id) => _getInfo(id)?.monsterLevels ?? 0;

  int getTotalLevels(CharID id) {
    final info = _getInfo(id);
    return info == null ? 0 : info.nonMonsterLevels + info.monsterLevels;
  }

  int getLevelAdjustment(CharID id) {
    // TODO: sum LA from race + templates
    return 0;
  }

  int getECL(CharID id) => getTotalLevels(id) + getLevelAdjustment(id);

  @override
  void levelChanged(ClassLevelChangeEvent lce) {
    final id = lce.getCharID();
    final info = _getConstructingInfo(id);
    final oldTotal = info.nonMonsterLevels + info.monsterLevels;
    if (lce.isMonster) {
      info.monsterLevels += lce.levelChange;
    } else {
      info.nonMonsterLevels += lce.levelChange;
    }
    final newTotal = info.nonMonsterLevels + info.monsterLevels;
    if (oldTotal != newTotal) {
      _support.fireLevelChange(id, oldTotal, newTotal);
    }
  }

  @override
  void levelObjectChanged(ClassLevelObjectChangeEvent lce) {
    // No level count change — object swap only
  }

  void addLevelChangeListener(LevelChangeListener listener) {
    _support.addLevelChangeListener(listener);
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final info = _getInfo(source);
    if (info != null) {
      final copyInfo = _getConstructingInfo(copy);
      copyInfo.monsterLevels = info.monsterLevels;
      copyInfo.nonMonsterLevels = info.nonMonsterLevels;
    }
  }

  _LevelCacheInfo? _getInfo(CharID id) => getCache(id) as _LevelCacheInfo?;

  _LevelCacheInfo _getConstructingInfo(CharID id) {
    var info = _getInfo(id);
    if (info == null) {
      info = _LevelCacheInfo();
      setCache(id, info);
    }
    return info;
  }
}

class _LevelCacheInfo {
  int monsterLevels = 0;
  int nonMonsterLevels = 0;
}

typedef LevelChangeListener = void Function(LevelChangeEvent lce);

class LevelChangeEvent {
  final CharID charID;
  final int oldLevel;
  final int newLevel;

  const LevelChangeEvent(this.charID, this.oldLevel, this.newLevel);

  CharID getCharID() => charID;
}

class LevelChangeSupport {
  final List<LevelChangeListener> _listeners = [];

  void addLevelChangeListener(LevelChangeListener listener) {
    _listeners.add(listener);
  }

  void removeLevelChangeListener(LevelChangeListener listener) {
    _listeners.remove(listener);
  }

  void fireLevelChange(CharID id, int oldLevel, int newLevel) {
    final event = LevelChangeEvent(id, oldLevel, newLevel);
    for (final listener in _listeners) {
      listener(event);
    }
  }
}
