// Translated from pcgen/rules/context/AbstractObjectContext.java
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net> - LGPL 2.1+

import '../../base/util/indirect.dart';
import '../../cdom/base/cdom_object.dart';
import '../../cdom/base/concrete_prereq_object.dart';
import '../../cdom/enumeration/fact_key.dart';
import '../../cdom/enumeration/fact_set_key.dart';
import '../../cdom/enumeration/formula_key.dart';
import '../../cdom/enumeration/integer_key.dart';
import '../../cdom/enumeration/list_key.dart';
import '../../cdom/enumeration/map_key.dart';
import '../../cdom/enumeration/object_key.dart';
import '../../cdom/enumeration/string_key.dart';
import '../../cdom/enumeration/variable_key.dart';
import 'changes.dart';
import 'collection_changes.dart';
import 'list_changes.dart';
import 'map_changes.dart';
import 'object_commit_strategy.dart';
import 'pattern_changes.dart';

// ---------------------------------------------------------------------------
// DummyCDOMObject — used as a tracking container inside TrackingObjectCommitStrategy
// ---------------------------------------------------------------------------

class DummyCDOMObject extends CDOMObject {
  @override
  bool isType(String str) => false;
}

// ---------------------------------------------------------------------------
// TrackingObjectCommitStrategy
// ---------------------------------------------------------------------------

class TrackingObjectCommitStrategy implements ObjectCommitStrategy {
  // DoubleKeyMap<URI, ConcretePrereqObject, CDOMObject>
  //   → Map<String?, Map<ConcretePrereqObject, CDOMObject>>
  final Map<String?, Map<ConcretePrereqObject, CDOMObject>> _positiveMap = {};
  final Map<String?, Map<ConcretePrereqObject, CDOMObject>> _negativeMap = {};

  // DoubleKeyMapToList<URI, CDOMObject, ListKey<?>>
  //   → Map<String?, Map<CDOMObject, List<ListKey>>>
  final Map<String?, Map<CDOMObject, List<ListKey<dynamic>>>> _globalClearSet =
      {};
  final Map<String?, Map<CDOMObject, List<FactSetKey<dynamic>>>>
      _globalClearFactSet = {};

  // HashMapToList<URI, ConcretePrereqObject>  →  Map<String?, List<ConcretePrereqObject>>
  final Map<String?, List<ConcretePrereqObject>> _preClearSet = {};

  // TripleKeyMapToList<URI, CDOMObject, ListKey, String>
  //   → Map<String?, Map<CDOMObject, Map<ListKey, List<String>>>>
  final Map<String?, Map<CDOMObject, Map<ListKey<dynamic>, List<String>>>>
      _patternClearSet = {};

  String? _sourceURI;
  String? _extractURI;

  String? getSourceURI() => _sourceURI;
  String? getExtractURI() => _extractURI;

  @override
  void setSourceURI(String? sourceURI) => _sourceURI = sourceURI;

  @override
  void setExtractURI(String? extractURI) => _extractURI = extractURI;

  CDOMObject _getNegative(String? source, CDOMObject cdo) {
    return _negativeMap
        .putIfAbsent(source, () => {})
        .putIfAbsent(cdo, () => DummyCDOMObject());
  }

  CDOMObject _getPositive(String? source, ConcretePrereqObject cdo) {
    return _positiveMap
        .putIfAbsent(source, () => {})
        .putIfAbsent(cdo, () => DummyCDOMObject());
  }

  @override
  void clearPrerequisiteList(ConcretePrereqObject cpo) {
    _preClearSet.putIfAbsent(_sourceURI, () => []).add(cpo);
  }

  @override
  void putPrerequisite(ConcretePrereqObject cpo, dynamic p) {
    _getPositive(_sourceURI, cpo).addPrerequisite(p);
  }

  @override
  void putString(CDOMObject cdo, StringKey sk, String s) {
    _getPositive(_sourceURI, cdo).putString(sk, s);
  }

  @override
  void removeString(CDOMObject cdo, StringKey sk) {
    _getNegative(_sourceURI, cdo)
        .addToListFor(ListKey.removedStringKey, sk);
  }

  @override
  void putObject<T>(CDOMObject cdo, ObjectKey<T> sk, T s) {
    _getPositive(_sourceURI, cdo).putObject(sk, s);
  }

  @override
  void removeObject(CDOMObject cdo, ObjectKey<dynamic> sk) {
    _getNegative(_sourceURI, cdo)
        .addToListFor(ListKey.removedObjectKey, sk);
  }

  @override
  void putFact<T>(CDOMObject cdo, FactKey<T> sk, Indirect<T> s) {
    _getPositive(_sourceURI, cdo).putFact(sk, s);
  }

  @override
  void removeFact(CDOMObject cdo, FactKey<dynamic> sk) {
    _getNegative(_sourceURI, cdo)
        .addToListFor(ListKey.removedFactKey, sk);
  }

  @override
  bool containsSetFor(CDOMObject cdo, FactSetKey<dynamic> key) {
    return cdo.containsSetFor(key);
  }

  @override
  void addToSet<T>(CDOMObject cdo, FactSetKey<T> key, Indirect<T> value) {
    _getPositive(_sourceURI, cdo).addToSetFor(key, value);
  }

  @override
  void removeSet(CDOMObject cdo, FactSetKey<dynamic> lk) {
    _globalClearFactSet.putIfAbsent(_sourceURI, () => {})
        .putIfAbsent(cdo, () => []).add(lk);
  }

  @override
  void removeFromSet<T>(CDOMObject cdo, FactSetKey<T> lk, Indirect<T> val) {
    _getNegative(_sourceURI, cdo).addToSetFor(lk, val);
  }

  @override
  void putInteger(CDOMObject cdo, IntegerKey ik, int i) {
    _getPositive(_sourceURI, cdo).putInteger(ik, i);
  }

  @override
  void removeInteger(CDOMObject cdo, IntegerKey ik) {
    _getNegative(_sourceURI, cdo)
        .addToListFor(ListKey.removedIntegerKey, ik);
  }

  @override
  void putFormula(CDOMObject cdo, FormulaKey fk, dynamic f) {
    _getPositive(_sourceURI, cdo).putFormula(fk, f);
  }

  @override
  void putVariable(CDOMObject obj, VariableKey vk, dynamic f) {
    _getPositive(_sourceURI, obj).putVariable(vk, f);
  }

  @override
  bool containsListFor(CDOMObject cdo, ListKey<dynamic> key) {
    return cdo.containsListFor(key);
  }

  @override
  void addToList<T>(CDOMObject cdo, ListKey<T> key, T value) {
    _getPositive(_sourceURI, cdo).addToListFor(key, value);
  }

  @override
  void removeList(CDOMObject cdo, ListKey<dynamic> lk) {
    _globalClearSet
        .putIfAbsent(_sourceURI, () => {})
        .putIfAbsent(cdo, () => [])
        .add(lk);
  }

  @override
  void removeFromList<T>(CDOMObject cdo, ListKey<T> lk, T val) {
    _getNegative(_sourceURI, cdo).addToListFor(lk, val);
  }

  @override
  void putMap<K, V>(CDOMObject cdo, MapKey<K, V> mk, K key, V value) {
    _getPositive(_sourceURI, cdo).addToMapFor(mk, key, value);
  }

  @override
  void removeMap<K, V>(CDOMObject cdo, MapKey<K, V> mk, K key) {
    _getNegative(_sourceURI, cdo).addToMapFor(mk, key, null);
  }

  @override
  MapChanges<K, V> getMapChanges<K, V>(CDOMObject cdo, MapKey<K, V> mk) {
    return MapChanges(
      _getPositive(_extractURI, cdo).getMapFor(mk),
      _getNegative(_extractURI, cdo).getMapFor(mk),
      false,
    );
  }

  @override
  String? getString(CDOMObject cdo, StringKey sk) {
    return _getPositive(_extractURI, cdo).getString(sk);
  }

  @override
  int? getInteger(CDOMObject cdo, IntegerKey ik) {
    return _getPositive(_extractURI, cdo).getInteger(ik);
  }

  @override
  dynamic getFormula(CDOMObject cdo, FormulaKey fk) {
    return _getPositive(_extractURI, cdo).getFormula(fk);
  }

  @override
  dynamic getVariable(CDOMObject cdo, VariableKey key) {
    return _getPositive(_extractURI, cdo).getVariable(key);
  }

  @override
  Set<VariableKey> getVariableKeys(CDOMObject cdo) {
    return _getPositive(_extractURI, cdo).getVariableKeys();
  }

  @override
  T? getObject<T>(CDOMObject cdo, ObjectKey<T> ik) {
    return _getPositive(_extractURI, cdo).getObject(ik);
  }

  @override
  Indirect<T>? getFact<T>(CDOMObject cdo, FactKey<T> ik) {
    return _getPositive(_extractURI, cdo).getFact(ik);
  }

  @override
  Changes<T> getListChanges<T>(CDOMObject cdo, ListKey<T> lk) {
    final hasClear =
        _globalClearSet[_extractURI]?[cdo]?.contains(lk) ?? false;
    return CollectionChanges(
      _getPositive(_extractURI, cdo).getListFor(lk),
      _getNegative(_extractURI, cdo).getListFor(lk),
      hasClear,
    );
  }

  @override
  Changes<Indirect<T>> getSetChanges<T>(CDOMObject cdo, FactSetKey<T> lk) {
    final hasClear =
        _globalClearFactSet[_extractURI]?[cdo]?.contains(lk) ?? false;
    return CollectionChanges(
      _getPositive(_extractURI, cdo).getSetFor(lk),
      _getNegative(_extractURI, cdo).getSetFor(lk),
      hasClear,
    );
  }

  @override
  PatternChanges<T> getListPatternChanges<T>(CDOMObject cdo, ListKey<T> lk) {
    final hasClear =
        _globalClearSet[_extractURI]?[cdo]?.contains(lk) ?? false;
    return PatternChanges(
      _getPositive(_extractURI, cdo).getListFor(lk),
      _patternClearSet[_extractURI]?[cdo]?[lk],
      hasClear,
    );
  }

  @override
  Changes<dynamic> getPrerequisiteChanges(ConcretePrereqObject obj) {
    final hasClear = _preClearSet[_extractURI]?.contains(obj) ?? false;
    return CollectionChanges(
      _getPositive(_extractURI, obj).getPrerequisiteList(),
      null,
      hasClear,
    );
  }

  @override
  void removePatternFromList<T>(CDOMObject cdo, ListKey<T> lk, String pattern) {
    _patternClearSet
        .putIfAbsent(_sourceURI, () => {})
        .putIfAbsent(cdo, () => {})
        .putIfAbsent(lk, () => [])
        .add(pattern);
  }

  @override
  bool wasRemovedObject(CDOMObject cdo, ObjectKey<dynamic> ok) {
    return _getNegative(_extractURI, cdo)
        .containsInList(ListKey.removedObjectKey, ok);
  }

  @override
  bool wasRemovedFact(CDOMObject cdo, FactKey<dynamic> ok) {
    return _getNegative(_extractURI, cdo)
        .containsInList(ListKey.removedFactKey, ok);
  }

  @override
  bool wasRemovedFactSet(CDOMObject cdo, FactSetKey<dynamic> ok) {
    return _getNegative(_extractURI, cdo)
        .containsInList(ListKey.removedFactSetKey, ok);
  }

  @override
  bool wasRemovedString(CDOMObject cdo, StringKey sk) {
    return _getNegative(_extractURI, cdo)
        .containsInList(ListKey.removedStringKey, sk);
  }

  @override
  bool wasRemovedInteger(CDOMObject cdo, IntegerKey ik) {
    return _getNegative(_extractURI, cdo)
        .containsInList(ListKey.removedIntegerKey, ik);
  }

  /// Creates a shallow clone of [obj] under a new [newName].
  /// stub: reflection-based clone replaced with direct instantiation per subclass
  CDOMObject? cloneConstructedCDOMObject(CDOMObject obj, String newName) {
    // stub: Java used Class.newInstance() via reflection
    // Dart callers must override this or provide a factory
    return null;
  }

  void decommit() {
    _positiveMap.clear();
    _negativeMap.clear();
    _globalClearSet.clear();
    _preClearSet.clear();
    _patternClearSet.clear();
  }

  void purge(CDOMObject cdo) {
    _positiveMap[_sourceURI]?.remove(cdo);
    _negativeMap[_sourceURI]?.remove(cdo);
    _globalClearSet[_sourceURI]?.remove(cdo);
    _preClearSet[_sourceURI]?.remove(cdo);
    _patternClearSet[_sourceURI]?.remove(cdo);
  }
}

// ---------------------------------------------------------------------------
// AbstractObjectContext
// ---------------------------------------------------------------------------

abstract class AbstractObjectContext implements ObjectCommitStrategy {
  final TrackingObjectCommitStrategy _edits = TrackingObjectCommitStrategy();

  @override
  void setSourceURI(String? sourceURI) {
    _edits.setSourceURI(sourceURI);
    getCommitStrategy().setSourceURI(sourceURI);
  }

  @override
  void setExtractURI(String? extractURI) {
    _edits.setExtractURI(extractURI);
    getCommitStrategy().setExtractURI(extractURI);
  }

  @override
  void addToList<T>(CDOMObject cdo, ListKey<T> key, T value) =>
      _edits.addToList(cdo, key, value);

  @override
  void addToSet<T>(CDOMObject cdo, FactSetKey<T> key, Indirect<T> value) =>
      _edits.addToSet(cdo, key, value);

  @override
  void putMap<K, V>(CDOMObject cdo, MapKey<K, V> mk, K key, V value) =>
      _edits.putMap(cdo, mk, key, value);

  @override
  void putFormula(CDOMObject cdo, FormulaKey fk, dynamic f) =>
      _edits.putFormula(cdo, fk, f);

  @override
  void putPrerequisite(ConcretePrereqObject cpo, dynamic p) =>
      _edits.putPrerequisite(cpo, p);

  @override
  void clearPrerequisiteList(ConcretePrereqObject cpo) =>
      _edits.clearPrerequisiteList(cpo);

  @override
  void putInteger(CDOMObject cdo, IntegerKey ik, int i) =>
      _edits.putInteger(cdo, ik, i);

  @override
  void removeInteger(CDOMObject cdo, IntegerKey ik) =>
      _edits.removeInteger(cdo, ik);

  @override
  void putObject<T>(CDOMObject cdo, ObjectKey<T> sk, T s) =>
      _edits.putObject(cdo, sk, s);

  @override
  void removeObject(CDOMObject cdo, ObjectKey<dynamic> sk) =>
      _edits.removeObject(cdo, sk);

  @override
  void putFact<T>(CDOMObject cdo, FactKey<T> sk, Indirect<T> s) =>
      _edits.putFact(cdo, sk, s);

  @override
  void removeFact(CDOMObject cdo, FactKey<dynamic> sk) =>
      _edits.removeFact(cdo, sk);

  @override
  void putString(CDOMObject cdo, StringKey sk, String s) =>
      _edits.putString(cdo, sk, s);

  @override
  void removeString(CDOMObject cdo, StringKey sk) =>
      _edits.removeString(cdo, sk);

  @override
  void putVariable(CDOMObject cdo, VariableKey vk, dynamic f) =>
      _edits.putVariable(cdo, vk, f);

  @override
  void removeFromList<T>(CDOMObject cdo, ListKey<T> lk, T val) =>
      _edits.removeFromList(cdo, lk, val);

  @override
  void removeList(CDOMObject cdo, ListKey<dynamic> lk) =>
      _edits.removeList(cdo, lk);

  @override
  void removeFromSet<T>(CDOMObject cdo, FactSetKey<T> lk, Indirect<T> val) =>
      _edits.removeFromSet(cdo, lk, val);

  @override
  void removeSet(CDOMObject cdo, FactSetKey<dynamic> lk) =>
      _edits.removeSet(cdo, lk);

  @override
  void removeMap<K, V>(CDOMObject cdo, MapKey<K, V> mk, K key) =>
      _edits.removeMap(cdo, mk, key);

  // ---- commit / rollback ----

  void commit() {
    final commit = getCommitStrategy();

    // Prerequisite clears
    for (final uri in _edits._preClearSet.keys) {
      for (final cpo in _edits._preClearSet[uri]!) {
        commit.clearPrerequisiteList(cpo);
      }
    }

    // Global list clears
    for (final uri in _edits._globalClearSet.keys) {
      final byOwner = _edits._globalClearSet[uri]!;
      for (final cdo in byOwner.keys) {
        for (final lk in byOwner[cdo]!) {
          commit.removeList(cdo, lk);
        }
      }
    }

    // Negative map — removals
    for (final uri in _edits._negativeMap.keys) {
      final byOwner = _edits._negativeMap[uri]!;
      for (final cpo in byOwner.keys) {
        if (cpo is CDOMObject) {
          final neg = byOwner[cpo]!;
          for (final ok
              in neg.getSafeListFor(ListKey.removedObjectKey)) {
            commit.removeObject(cpo, ok);
          }
          for (final ok
              in neg.getSafeListFor(ListKey.removedFactKey)) {
            commit.removeFact(cpo, ok);
          }
          for (final sk
              in neg.getSafeListFor(ListKey.removedStringKey)) {
            commit.removeString(cpo, sk);
          }
          for (final ik
              in neg.getSafeListFor(ListKey.removedIntegerKey)) {
            commit.removeInteger(cpo, ik);
          }
          for (final key in neg.getFactSetKeys()) {
            _removeFactSetKey(cpo, key, neg);
          }
          for (final key in neg.getListKeys()) {
            _removeListKey(cpo, key, neg);
          }
          for (final key in neg.getMapKeys()) {
            _removeMapKey(cpo, key, neg);
          }
        }
      }
    }

    // Positive map — additions
    for (final uri in _edits._positiveMap.keys) {
      final byOwner = _edits._positiveMap[uri]!;
      for (final cpo in byOwner.keys) {
        final pos = byOwner[cpo]!;
        for (final p in pos.getPrerequisiteList()) {
          commit.putPrerequisite(cpo, p);
        }
        if (cpo is CDOMObject) {
          for (final key in pos.getStringKeys()) {
            commit.putString(cpo, key, pos.getString(key)!);
          }
          for (final key in pos.getIntegerKeys()) {
            commit.putInteger(cpo, key, pos.getInteger(key)!);
          }
          for (final key in pos.getFormulaKeys()) {
            commit.putFormula(cpo, key, pos.getFormula(key));
          }
          for (final key in pos.getVariableKeys()) {
            commit.putVariable(cpo, key, pos.getVariable(key));
          }
          for (final key in pos.getObjectKeys()) {
            _putObjectKey(cpo, key, pos);
          }
          for (final key in pos.getFactKeys()) {
            _putFactKey(cpo, key, pos);
          }
          for (final key in pos.getListKeys()) {
            _putListKey(cpo, key, pos);
          }
          for (final key in pos.getFactSetKeys()) {
            _putFactSetKey(cpo, key, pos);
          }
          for (final key in pos.getMapKeys()) {
            _putMapKey(cpo, key, pos);
          }
        }
      }
    }

    // Pattern clears
    for (final uri in _edits._patternClearSet.keys) {
      final byOwner = _edits._patternClearSet[uri]!;
      for (final cdo in byOwner.keys) {
        final byKey = byOwner[cdo]!;
        for (final lk in byKey.keys) {
          for (final s in byKey[lk]!) {
            commit.removePatternFromList(cdo, lk, s);
          }
        }
      }
    }

    rollback();
  }

  void _removeListKey<T>(CDOMObject cdo, ListKey<T> key, CDOMObject neg) {
    for (final obj in neg.getListFor(key)) {
      getCommitStrategy().removeFromList(cdo, key, obj);
    }
  }

  void _removeFactSetKey<T>(
      CDOMObject cdo, FactSetKey<T> key, CDOMObject neg) {
    for (final obj in neg.getSetFor(key)) {
      getCommitStrategy().removeFromSet(cdo, key, obj);
    }
  }

  void _putListKey<T>(CDOMObject cdo, ListKey<T> key, CDOMObject pos) {
    for (final obj in pos.getListFor(key)) {
      getCommitStrategy().addToList(cdo, key, obj);
    }
  }

  void _putFactSetKey<T>(CDOMObject cdo, FactSetKey<T> key, CDOMObject pos) {
    for (final obj in pos.getSetFor(key)) {
      getCommitStrategy().addToSet(cdo, key, obj);
    }
  }

  void _putObjectKey<T>(CDOMObject cdo, ObjectKey<T> key, CDOMObject pos) {
    getCommitStrategy().putObject(cdo, key, pos.getObject(key) as T);
  }

  void _putFactKey<T>(CDOMObject cdo, FactKey<T> key, CDOMObject pos) {
    getCommitStrategy().putFact(cdo, key, pos.getFact(key) as Indirect<T>);
  }

  void _removeMapKey<K, V>(CDOMObject cdo, MapKey<K, V> key, CDOMObject neg) {
    for (final k in neg.getKeysFor(key)) {
      getCommitStrategy().removeMap(cdo, key, k);
    }
  }

  void _putMapKey<K, V>(CDOMObject cdo, MapKey<K, V> key, CDOMObject pos) {
    for (final k in pos.getKeysFor(key)) {
      getCommitStrategy().putMap(cdo, key, k, pos.getMap(key, k) as V);
    }
  }

  void rollback() {
    _edits.decommit();
  }

  // ---- query delegates ----

  @override
  dynamic getFormula(CDOMObject cdo, FormulaKey fk) =>
      getCommitStrategy().getFormula(cdo, fk);

  @override
  int? getInteger(CDOMObject cdo, IntegerKey ik) =>
      getCommitStrategy().getInteger(cdo, ik);

  @override
  Changes<T> getListChanges<T>(CDOMObject cdo, ListKey<T> lk) =>
      getCommitStrategy().getListChanges(cdo, lk);

  @override
  Changes<Indirect<T>> getSetChanges<T>(CDOMObject cdo, FactSetKey<T> lk) =>
      getCommitStrategy().getSetChanges(cdo, lk);

  @override
  MapChanges<K, V> getMapChanges<K, V>(CDOMObject cdo, MapKey<K, V> mk) =>
      getCommitStrategy().getMapChanges(cdo, mk);

  @override
  T? getObject<T>(CDOMObject cdo, ObjectKey<T> ik) =>
      getCommitStrategy().getObject(cdo, ik);

  @override
  Indirect<T>? getFact<T>(CDOMObject cdo, FactKey<T> ik) =>
      getCommitStrategy().getFact(cdo, ik);

  @override
  String? getString(CDOMObject cdo, StringKey sk) =>
      getCommitStrategy().getString(cdo, sk);

  @override
  dynamic getVariable(CDOMObject obj, VariableKey key) =>
      getCommitStrategy().getVariable(obj, key);

  @override
  Set<VariableKey> getVariableKeys(CDOMObject obj) =>
      getCommitStrategy().getVariableKeys(obj);

  CDOMObject? cloneConstructedCDOMObject(CDOMObject obj, String newName) {
    return _edits.cloneConstructedCDOMObject(obj, newName);
  }

  @override
  Changes<dynamic> getPrerequisiteChanges(ConcretePrereqObject obj) =>
      getCommitStrategy().getPrerequisiteChanges(obj);

  @override
  bool containsListFor(CDOMObject obj, ListKey<dynamic> lk) =>
      getCommitStrategy().containsListFor(obj, lk);

  @override
  bool containsSetFor(CDOMObject obj, FactSetKey<dynamic> lk) =>
      getCommitStrategy().containsSetFor(obj, lk);

  @override
  void removePatternFromList<T>(CDOMObject cdo, ListKey<T> lk, String pattern) =>
      _edits.removePatternFromList(cdo, lk, pattern);

  @override
  PatternChanges<T> getListPatternChanges<T>(CDOMObject cdo, ListKey<T> lk) =>
      getCommitStrategy().getListPatternChanges(cdo, lk);

  @override
  bool wasRemovedObject(CDOMObject cdo, ObjectKey<dynamic> ok) =>
      getCommitStrategy().wasRemovedObject(cdo, ok);

  @override
  bool wasRemovedFact(CDOMObject cdo, FactKey<dynamic> sk) =>
      getCommitStrategy().wasRemovedFact(cdo, sk);

  @override
  bool wasRemovedFactSet(CDOMObject cdo, FactSetKey<dynamic> sk) =>
      getCommitStrategy().wasRemovedFactSet(cdo, sk);

  @override
  bool wasRemovedString(CDOMObject cdo, StringKey sk) =>
      getCommitStrategy().wasRemovedString(cdo, sk);

  @override
  bool wasRemovedInteger(CDOMObject cdo, IntegerKey ik) =>
      getCommitStrategy().wasRemovedInteger(cdo, ik);

  ObjectCommitStrategy getCommitStrategy();
}
