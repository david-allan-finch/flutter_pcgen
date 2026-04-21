// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.BonusChangeFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_storage_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/bonus_checking_facet.dart';

/// Tracks bonus values and fires [BonusChangeEvent]s when they change.
class BonusChangeFacet extends AbstractStorageFacet<CharID> {
  final _support = BonusChangeSupport();
  late BonusCheckingFacet bonusCheckingFacet;

  /// Checks current bonus values against cached values; fires events on change.
  void reset(CharID id) {
    final map = _getConstructingInfo(id);
    for (final type in _support.getBonusTypes()) {
      for (final name in _support.getBonusNames(type)) {
        final newValue = bonusCheckingFacet.getBonus(id, type, name);
        final oldValue = map[type]?[name];
        if (newValue != oldValue) {
          (map[type] ??= {})[name] = newValue;
          _support.fireBonusChange(id, type, name, oldValue, newValue);
        }
      }
    }
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final map = _getInfo(source);
    if (map != null) {
      final copyMap = _getConstructingInfo(copy);
      for (final entry in map.entries) {
        (copyMap[entry.key] ??= {}).addAll(entry.value);
      }
    }
  }

  void addBonusChangeListener(BonusChangeListener listener, String type, String name) {
    _support.addBonusChangeListener(listener, type, name);
  }

  void removeBonusChangeListener(BonusChangeListener listener, String type, String name) {
    _support.removeBonusChangeListener(listener, type, name);
  }

  Map<String, Map<String, double>>? _getInfo(CharID id) =>
      getCache(id) as Map<String, Map<String, double>>?;

  Map<String, Map<String, double>> _getConstructingInfo(CharID id) {
    var map = _getInfo(id);
    if (map == null) {
      map = {};
      setCache(id, map);
    }
    return map;
  }
}

typedef BonusChangeListener = void Function(BonusChangeEvent bce);

class BonusChangeEvent {
  final CharID charID;
  final String bonusType;
  final String bonusName;
  final num? oldVal;
  final num newVal;

  const BonusChangeEvent(
      this.charID, this.bonusType, this.bonusName, this.oldVal, this.newVal);
}

class BonusChangeSupport {
  final Map<String, Map<String, List<BonusChangeListener>>> _listeners = {};

  void addBonusChangeListener(BonusChangeListener listener, String type, String name) {
    ((_listeners[type] ??= {})[name] ??= []).add(listener);
  }

  void removeBonusChangeListener(BonusChangeListener listener, String type, String name) {
    _listeners[type]?[name]?.remove(listener);
  }

  Iterable<String> getBonusTypes() => _listeners.keys;

  Iterable<String> getBonusNames(String type) =>
      _listeners[type]?.keys ?? const [];

  void fireBonusChange(
      CharID id, String type, String name, num? oldValue, num newValue) {
    final bce = BonusChangeEvent(id, type, name, oldValue, newValue);
    final list = _listeners[type]?[name];
    if (list != null) {
      for (final target in list) {
        target(bce);
      }
    }
  }
}
