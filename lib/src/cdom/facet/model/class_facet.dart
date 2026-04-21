// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_data_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';

// stub: OutputDB.register("classes", this)
// dynamic: PCClass (not yet translated)
// dynamic: PCClassLevel (not yet translated)

/// ClassFacet is a Facet that tracks the PCClass objects possessed by a Player
/// Character.
class ClassFacet extends AbstractDataFacet<CharID, dynamic> {
  final ClassLevelChangeSupport _support = ClassLevelChangeSupport();

  /// Add the given PCClass to the list of PCClass objects stored in this
  /// ClassFacet for the Player Character represented by the given CharID.
  void addClass(CharID id, dynamic obj) {
    if (obj == null) throw ArgumentError('PCClass to add may not be null');
    if (_getConstructingClassInfo(id).addClass(obj)) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataAdded);
    }
  }

  /// Sets the PCClassLevel object associated with the given PCClass for the
  /// Player Character represented by the given CharID.
  bool setClassLevel(CharID id, dynamic pcc, dynamic pcl) {
    if (pcc == null) throw ArgumentError('Class cannot be null in setClassLevel');
    if (pcl == null) throw ArgumentError('Class Level cannot be null in setClassLevel');
    final info = _getClassInfo(id);
    if (info == null) return false;
    final old = info.getClassLevel(pcc, pcl.getLevel() as int);
    final returnVal = info.setClassLevel(pcc, pcl);
    _support.fireClassLevelObjectChangeEvent(id, pcc, old, pcl);
    return returnVal;
  }

  /// Returns the PCClassLevel associated with the given PCClass and numeric level.
  dynamic getClassLevel(CharID id, dynamic obj, int level) {
    final info = _getClassInfo(id);
    if (info == null) return null;
    return info.getClassLevel(obj, level);
  }

  /// Remove the given PCClass from this ClassFacet for the given CharID.
  void removeClass(CharID id, dynamic obj) {
    if (obj == null) throw ArgumentError('PCClass to remove may not be null');
    final info = _getClassInfo(id);
    if (info != null) {
      if (info.containsClass(obj)) {
        setLevel(id, obj, 0);
        info.removeClass(obj);
        fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
      }
      if (info.isEmpty) {
        removeCache(id);
      }
    }
  }

  /// Removes all PCClass objects from this ClassFacet for the given CharID.
  ClassInfo? removeAllClasses(CharID id) {
    final info = removeCache(id) as ClassInfo?;
    if (info != null) {
      for (final obj in info.getClassSet()) {
        fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
        final oldLevel = info.getLevel(obj);
        _support.fireClassLevelChangeEvent(id, obj, oldLevel, 0);
      }
    }
    return info;
  }

  /// Replaces the given old PCClass with the new PCClass for the given CharID.
  void replaceClass(CharID id, dynamic oldClass, dynamic newClass) {
    final info = _getClassInfo(id);
    if (info != null) {
      info.replace(oldClass, newClass);
    }
  }

  /// Returns an unmodifiable Set of PCClass objects for the given CharID.
  Set<dynamic> getSet(CharID id) {
    final info = _getClassInfo(id);
    if (info == null) return const {};
    return info.getClassSet();
  }

  /// Returns the count of PCClass objects for the given CharID.
  int getCount(CharID id) {
    final info = _getClassInfo(id);
    if (info == null) return 0;
    return info.classCount();
  }

  /// Returns true if no PCClass objects exist for the given CharID.
  bool isEmpty(CharID id) {
    final info = _getClassInfo(id);
    return info == null || info.isEmpty;
  }

  /// Returns true if this ClassFacet contains the given PCClass for the given CharID.
  bool contains(CharID id, dynamic obj) {
    final info = _getClassInfo(id);
    return info != null && info.containsClass(obj);
  }

  /// Sets the level for the given PCClass and CharID.
  void setLevel(CharID id, dynamic pcc, int level) {
    final oldLevel = _getConstructingClassInfo(id).setLevel(pcc, level);
    _support.fireClassLevelChangeEvent(id, pcc, oldLevel, level);
  }

  /// Returns the current level for the given PCClass and CharID.
  int getLevel(CharID id, dynamic pcc) {
    final info = _getClassInfo(id);
    return (info == null) ? 0 : info.getLevel(pcc);
  }

  ClassInfo? _getClassInfo(CharID id) {
    return getCache(id) as ClassInfo?;
  }

  ClassInfo _getConstructingClassInfo(CharID id) {
    ClassInfo? info = _getClassInfo(id);
    if (info == null) {
      info = ClassInfo();
      setCache(id, info);
    }
    return info;
  }

  @override
  void copyContents(CharID source, CharID destination) {
    final info = _getClassInfo(source);
    if (info != null) {
      setCache(destination, ClassInfo.copy(info));
    }
  }

  void addLevelChangeListener(ClassLevelChangeListener listener) {
    _support.addLevelChangeListener(listener);
  }

  List<ClassLevelChangeListener> getLevelChangeListeners() {
    return _support.getLevelChangeListeners();
  }

  void removeLevelChangeListener(ClassLevelChangeListener listener) {
    _support.removeLevelChangeListener(listener);
  }

  void init() {
    // stub: OutputDB.register("classes", this)
  }
}

/// ClassInfo stores PCClassLevel objects and levels for a Player Character.
class ClassInfo {
  /// Map from PCClass to its levels (Integer -> PCClassLevel).
  final Map<dynamic, Map<int, dynamic>> _map = {};

  /// Map from PCClass to its numeric level.
  final Map<dynamic, int> _levelmap = {};

  ClassInfo();

  ClassInfo.copy(ClassInfo info) {
    for (final entry in info._map.entries) {
      _map[entry.key] = Map<int, dynamic>.from(entry.value);
    }
    _levelmap.addAll(info._levelmap);
  }

  int setLevel(dynamic pcc, int level) {
    if (pcc == null) throw ArgumentError('Class for setLevel must not be null');
    if (level < 0) {
      throw ArgumentError('Level for class must be > 0');
    }
    if (level != 0 && !_map.containsKey(pcc)) {
      throw ArgumentError('Cannot set level for PCClass which is not added');
    }
    final oldlvl = _levelmap[pcc];
    _levelmap[pcc] = level;
    return oldlvl ?? 0;
  }

  int getLevel(dynamic pcc) {
    return _levelmap[pcc] ?? 0;
  }

  void replace(dynamic oldClass, dynamic newClass) {
    final oldMap = Map<dynamic, Map<int, dynamic>>.from(_map);
    _map.clear();
    for (final entry in oldMap.entries) {
      if (oldClass == entry.key) {
        addClass(newClass);
      } else {
        _map[entry.key] = entry.value;
      }
    }
  }

  bool addClass(dynamic pcc) {
    if (_map.containsKey(pcc)) return false;
    _map[pcc] = {};
    return true;
  }

  bool setClassLevel(dynamic pcc, dynamic pcl) {
    final localMap = _map[pcc];
    if (localMap == null) return false;
    // stub: pcl.ownBonuses(pcc); pcl.put(ObjectKey.PARENT, pcc);
    localMap[pcl.getLevel() as int] = pcl;
    return true;
  }

  dynamic getClassLevel(dynamic pcc, int level) {
    if (pcc == null) throw ArgumentError('Class in getClassLevel cannot be null');
    if (level < 0) throw ArgumentError('Level cannot be negative in getClassLevel');
    Map<int, dynamic>? localMap;
    for (final entry in _map.entries) {
      if (pcc == entry.key) {
        localMap = entry.value;
        break;
      }
    }
    if (localMap == null) {
      throw ArgumentError('Level cannot be returned for Class which is not in the PC');
    }
    dynamic classLevel = localMap[level];
    if (classLevel == null) {
      // stub: classLevel = pcc.getOriginalClassLevel(level); classLevel.put(ObjectKey.PARENT, pcc);
      localMap[level] = classLevel;
    }
    return classLevel;
  }

  bool removeClass(dynamic pcc) {
    final had = _map.containsKey(pcc);
    _map.remove(pcc);
    return had;
  }

  Set<dynamic> getClassSet() {
    return Set.unmodifiable(_map.keys.toSet());
  }

  bool isEmpty() => _map.isEmpty;

  int classCount() => _map.length;

  bool containsClass(dynamic pcc) => _map.containsKey(pcc);

  @override
  bool operator ==(Object o) {
    if (o is ClassInfo) {
      return _map == o._map && _levelmap == o._levelmap;
    }
    return false;
  }

  @override
  int get hashCode => _map.hashCode;
}

/// Listener interface for class level changes.
abstract interface class ClassLevelChangeListener {
  void levelChanged(ClassLevelChangeEvent lce);
  void levelObjectChanged(ClassLevelObjectChangeEvent lce);
}

/// Event fired when the numeric level of a PCClass changes.
class ClassLevelChangeEvent {
  final CharID charID;
  final dynamic pcClass;
  final int oldLvl;
  final int newLvl;

  ClassLevelChangeEvent(CharID source, dynamic pcc, int oldLevel, int newLevel)
      : charID = source,
        pcClass = pcc,
        oldLvl = oldLevel,
        newLvl = newLevel;

  CharID getCharID() => charID;
  dynamic getPCClass() => pcClass;
  int getOldLevel() => oldLvl;
  int getNewLevel() => newLvl;
}

/// Event fired when the PCClassLevel object for a PCClass changes.
class ClassLevelObjectChangeEvent {
  final CharID charID;
  final dynamic pcClass;
  final dynamic oldLvl;
  final dynamic newLvl;

  ClassLevelObjectChangeEvent(
      CharID source, dynamic pcc, dynamic oldLevel, dynamic newLevel)
      : charID = source,
        pcClass = pcc,
        oldLvl = oldLevel,
        newLvl = newLevel;

  CharID getCharID() => charID;
  dynamic getPCClass() => pcClass;
  dynamic getOldLevel() => oldLvl;
  dynamic getNewLevel() => newLvl;
}

/// Support class that manages listeners for class level change events.
class ClassLevelChangeSupport {
  final List<ClassLevelChangeListener> _listeners = [];

  void addLevelChangeListener(ClassLevelChangeListener listener) {
    _listeners.add(listener);
  }

  List<ClassLevelChangeListener> getLevelChangeListeners() {
    return List.unmodifiable(_listeners);
  }

  void removeLevelChangeListener(ClassLevelChangeListener listener) {
    _listeners.remove(listener);
  }

  void fireClassLevelChangeEvent(
      CharID id, dynamic pcc, int oldLevel, int newLevel) {
    if (oldLevel == newLevel) return;
    ClassLevelChangeEvent? ccEvent;
    for (int i = _listeners.length - 1; i >= 0; i--) {
      ccEvent ??= ClassLevelChangeEvent(id, pcc, oldLevel, newLevel);
      _listeners[i].levelChanged(ccEvent);
    }
  }

  void fireClassLevelObjectChangeEvent(
      CharID id, dynamic pcc, dynamic oldLevel, dynamic newLevel) {
    if (identical(oldLevel, newLevel)) return;
    ClassLevelObjectChangeEvent? ccEvent;
    for (int i = _listeners.length - 1; i >= 0; i--) {
      ccEvent ??= ClassLevelObjectChangeEvent(id, pcc, oldLevel, newLevel);
      _listeners[i].levelObjectChanged(ccEvent);
    }
  }
}
