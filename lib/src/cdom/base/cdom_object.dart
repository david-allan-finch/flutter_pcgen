//
// Copyright (c) 2007-18 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.base.CDOMObject
import '../../base/util/indirect.dart';
import '../../base/util/object_container.dart';
import '../enumeration/fact_key.dart';
import '../enumeration/fact_set_key.dart';
import '../enumeration/formula_key.dart';
import '../enumeration/integer_key.dart';
import '../enumeration/list_key.dart';
import '../enumeration/map_key.dart';
import '../enumeration/object_key.dart';
import '../enumeration/string_key.dart';
import '../enumeration/variable_key.dart';
import '../formula/pcgen_scoped.dart';
import '../util/fact_set_key_map_to_list.dart';
import '../util/list_key_map_to_list.dart';
import '../util/map_key_map.dart';
import 'bonus_container.dart';
import 'concrete_prereq_object.dart';
import 'loadable.dart';
import 'reducible.dart';
import 'var_container.dart';
import 'var_holder.dart';

// The central abstract base class for all game objects.
abstract class CDOMObject extends ConcretePrereqObject
    implements BonusContainer, Loadable, Reducible, PCGenScoped, VarHolder, VarContainer {

  static int Function(CDOMObject, CDOMObject) pObjectComp =
      (o1, o2) => o1.getKeyName().toLowerCase().compareTo(o2.getKeyName().toLowerCase());

  static int Function(CDOMObject, CDOMObject) pObjectNameComp = (o1, o2) {
    String key1 = o1.get(StringKey.sortKey) ?? o1.getDisplayName();
    String key2 = o2.get(StringKey.sortKey) ?? o2.getDisplayName();
    if (key1 != key2) return key1.compareTo(key2);
    if (o1.getDisplayName() != o2.getDisplayName()) {
      return o1.getDisplayName().compareTo(o2.getDisplayName());
    }
    return o1.getKeyName().compareTo(o2.getKeyName());
  };

  String? _sourceURI;
  String _displayName = '';

  Map<IntegerKey, int>? _integerChar;
  Map<StringKey, String>? _stringChar;
  Map<FormulaKey, String>? _formulaChar;  // Formula stored as String expression
  Map<VariableKey, String>? _variableChar;
  Map<ObjectKey<dynamic>, dynamic>? _objectChar;
  Map<FactKey<dynamic>, dynamic>? _factChar;
  FactSetKeyMapToList? _factSetChar;
  ListKeyMapToList? _listChar;
  MapKeyMap? _mapChar;

  // --- IntegerKey methods ---

  bool containsIntegerKey(IntegerKey key) =>
      _integerChar != null && _integerChar!.containsKey(key);

  int? get(IntegerKey key) => _integerChar?[key];

  int getSafeInt(IntegerKey key) {
    return _integerChar?[key] ?? key.getDefault();
  }

  int? putInt(IntegerKey key, int intValue) {
    _integerChar ??= {};
    return _integerChar![key] = intValue;
  }

  int? removeInt(IntegerKey key) {
    final out = _integerChar?.remove(key);
    if (out != null && _integerChar!.isEmpty) _integerChar = null;
    return out;
  }

  Set<IntegerKey> getIntegerKeys() =>
      _integerChar == null ? {} : Set.of(_integerChar!.keys);

  // --- StringKey methods ---

  bool containsStringKey(StringKey key) =>
      _stringChar != null && _stringChar!.containsKey(key);

  String? get(StringKey key) => _stringChar?[key];

  String getSafeString(StringKey key) => _stringChar?[key] ?? '';

  String? putString(StringKey key, String value) {
    _stringChar ??= {};
    return _stringChar![key] = value;
  }

  String? removeString(StringKey key) {
    final out = _stringChar?.remove(key);
    if (out != null && _stringChar!.isEmpty) _stringChar = null;
    return out;
  }

  Set<StringKey> getStringKeys() =>
      _stringChar == null ? {} : Set.of(_stringChar!.keys);

  // --- FormulaKey methods (formula stored as String expression) ---

  bool containsFormulaKey(FormulaKey key) =>
      _formulaChar != null && _formulaChar!.containsKey(key);

  String? getFormula(FormulaKey key) => _formulaChar?[key];

  String getSafeFormula(FormulaKey key) => _formulaChar?[key] ?? key.getDefault();

  String? putFormula(FormulaKey key, String value) {
    _formulaChar ??= {};
    return _formulaChar![key] = value;
  }

  String? removeFormula(FormulaKey key) {
    final out = _formulaChar?.remove(key);
    if (out != null && _formulaChar!.isEmpty) _formulaChar = null;
    return out;
  }

  Set<FormulaKey> getFormulaKeys() =>
      _formulaChar == null ? {} : Set.of(_formulaChar!.keys);

  // --- VariableKey methods ---

  bool containsVariableKey(VariableKey key) =>
      _variableChar != null && _variableChar!.containsKey(key);

  String? getVariable(VariableKey key) => _variableChar?[key];

  Set<VariableKey> getVariableKeys() =>
      _variableChar == null ? {} : Set.of(_variableChar!.keys);

  String? putVariable(VariableKey key, String value) {
    _variableChar ??= {};
    return _variableChar![key] = value;
  }

  String? removeVariable(VariableKey key) {
    final out = _variableChar?.remove(key);
    if (out != null && _variableChar!.isEmpty) _variableChar = null;
    return out;
  }

  void removeAllVariables() {
    _variableChar = null;
  }

  // --- ObjectKey methods ---

  bool containsObjectKey(ObjectKey<dynamic> key) =>
      _objectChar != null && _objectChar!.containsKey(key);

  OT? getObject<OT>(ObjectKey<OT> key) {
    return _objectChar == null ? null : key.cast(_objectChar![key]);
  }

  OT? getSafeObject<OT>(ObjectKey<OT> key) {
    final obj = getObject(key);
    return obj ?? key.getDefault();
  }

  OT? putObject<OT>(ObjectKey<OT> key, OT value) {
    _objectChar ??= {};
    return key.cast(_objectChar![key] = value);
  }

  OT? removeObject<OT>(ObjectKey<OT> key) {
    final out = _objectChar == null ? null : key.cast(_objectChar!.remove(key));
    if (out != null && _objectChar!.isEmpty) _objectChar = null;
    return out;
  }

  Set<ObjectKey<dynamic>> getObjectKeys() =>
      _objectChar == null ? {} : Set.of(_objectChar!.keys);

  // --- FactKey methods ---

  bool containsFactKey(FactKey<dynamic> key) =>
      _factChar != null && _factChar!.containsKey(key);

  Indirect<FT>? getFact<FT>(FactKey<FT> key) {
    return _factChar?[key] as Indirect<FT>?;
  }

  FT? getResolvedFact<FT>(FactKey<FT> key) {
    return (getFact(key) as Indirect<FT>?)?.get();
  }

  void putFact<FT>(FactKey<FT> key, Indirect<FT> value) {
    _factChar ??= {};
    _factChar![key] = value;
  }

  FT? removeFact<FT>(FactKey<FT> key) {
    final out = _factChar?.remove(key) as FT?;
    if (out != null && _factChar!.isEmpty) _factChar = null;
    return out;
  }

  Set<FactKey<dynamic>> getFactKeys() =>
      _factChar == null ? {} : Set.of(_factChar!.keys);

  // --- FactSetKey methods ---

  bool containsSetFor(FactSetKey<dynamic> key) =>
      _factSetChar != null && _factSetChar!.containsListFor(key);

  void addToSetFor<T>(FactSetKey<T> key, Indirect<T> element) {
    _factSetChar ??= FactSetKeyMapToList();
    _factSetChar!.addToListFor(key, element);
  }

  void addAllToSetFor<T>(FactSetKey<T> key, Iterable<ObjectContainer<T>> elements) {
    _factSetChar ??= FactSetKeyMapToList();
    _factSetChar!.addAllToListFor(key, elements);
  }

  List<dynamic>? getSetFor<T>(FactSetKey<T> key) {
    return _factSetChar?.getListFor(key);
  }

  List<dynamic> getSafeSetFor<T>(FactSetKey<T> key) {
    return (_factSetChar != null && _factSetChar!.containsListFor(key))
        ? _factSetChar!.getListFor(key)!
        : [];
  }

  int getSizeOfSetFor(FactSetKey<dynamic> key) =>
      _factSetChar?.sizeOfListFor(key) ?? 0;

  int getSafeSizeOfSetFor(FactSetKey<dynamic> key) {
    if (_factSetChar == null) return 0;
    return _factSetChar!.containsListFor(key)
        ? _factSetChar!.sizeOfListFor(key)
        : 0;
  }

  bool containsInSet<T>(FactSetKey<T> key, ObjectContainer<T> element) =>
      _factSetChar?.containsInList(key, element) ?? false;

  List<dynamic>? removeSetFor<T>(FactSetKey<T> key) {
    final out = _factSetChar?.removeListFor(key);
    if (out != null && (_factSetChar?.isEmpty ?? false)) _factSetChar = null;
    return out;
  }

  bool removeFromSetFor<T>(FactSetKey<T> key, Indirect<T> element) {
    final removed = _factSetChar?.removeFromListFor(key, element) ?? false;
    if (removed && (_factSetChar?.isEmpty ?? false)) _factSetChar = null;
    return removed;
  }

  Set<FactSetKey<dynamic>> getFactSetKeys() =>
      _factSetChar == null ? {} : _factSetChar!.getKeySet();

  // --- ListKey methods ---

  bool containsListFor(ListKey<dynamic> key) =>
      _listChar != null && _listChar!.containsListFor(key);

  void addToListFor<T>(ListKey<T> key, T element) {
    _listChar ??= ListKeyMapToList();
    _listChar!.addToListFor(key, element);
  }

  void addAllToListFor<T>(ListKey<T> key, Iterable<T> elements) {
    _listChar ??= ListKeyMapToList();
    _listChar!.addAllToListFor(key, elements);
  }

  List<T>? getListFor<T>(ListKey<T> key) =>
      _listChar?.getListFor(key);

  List<T> getSafeListFor<T>(ListKey<T> key) {
    return (_listChar != null && _listChar!.containsListFor(key))
        ? _listChar!.getListFor(key)!
        : [];
  }

  Set<T> getUniqueListFor<T>(ListKey<T> key) {
    if (_listChar == null) return {};
    final list = _listChar!.getListFor(key);
    if (list == null) return {};
    return LinkedHashSet<T>.from(list);
  }

  String getListAsString(ListKey<dynamic> key) {
    final list = getListFor(key);
    if (list == null) return '';
    return list.join(', ');
  }

  int getSizeOfListFor(ListKey<dynamic> key) =>
      _listChar?.sizeOfListFor(key) ?? 0;

  int getSafeSizeOfListFor(ListKey<dynamic> key) {
    if (_listChar == null) return 0;
    return _listChar!.containsListFor(key)
        ? _listChar!.sizeOfListFor(key)
        : 0;
  }

  bool containsInList<T>(ListKey<T> key, T element) =>
      _listChar?.containsInList(key, element) ?? false;

  bool containsAnyInList<T>(ListKey<T> key, Iterable<T> elements) =>
      _listChar?.containsAnyInList(key, elements) ?? false;

  T? getElementInList<T>(ListKey<T> key, int index) =>
      _listChar?.getElementInList(key, index);

  List<T>? removeListFor<T>(ListKey<T> key) {
    final out = _listChar?.removeListFor(key);
    if (out != null && (_listChar?.isEmpty ?? false)) _listChar = null;
    return out;
  }

  bool removeFromListFor<T>(ListKey<T> key, T element) {
    final removed = _listChar?.removeFromListFor(key, element) ?? false;
    if (removed && (_listChar?.isEmpty ?? false)) _listChar = null;
    return removed;
  }

  Set<ListKey<dynamic>> getListKeys() =>
      _listChar == null ? {} : _listChar!.getKeySet();

  // --- MapKey methods ---

  V? addToMapFor<K, V>(MapKey<K, V> mapKey, K key, V value) {
    _mapChar ??= MapKeyMap();
    return _mapChar!.addToMapFor(mapKey, key, value) as V?;
  }

  void removeFromMapFor<K, V>(MapKey<K, V> mapKey, K key) {
    if (_mapChar != null) {
      _mapChar!.removeFromMapFor(mapKey, key);
      if (_mapChar!.isEmpty) _mapChar = null;
    }
  }

  void removeMapFor<K, V>(MapKey<K, V> mapKey) {
    if (_mapChar != null) {
      _mapChar!.removeMapFor(mapKey);
      if (_mapChar!.isEmpty) _mapChar = null;
    }
  }

  Map<K, V> getMapFor<K, V>(MapKey<K, V> mapKey) =>
      _mapChar == null ? {} : _mapChar!.getMapFor(mapKey);

  Set<K> getKeysFor<K, V>(MapKey<K, V> mapKey) =>
      _mapChar == null ? {} : _mapChar!.getKeysFor(mapKey);

  V? getMap<K, V>(MapKey<K, V> mapKey, K key2) =>
      _mapChar?.get(mapKey, key2);

  bool removeFromMap<K, V>(MapKey<K, V> mapKey, K key2) {
    final removed = _mapChar?.removeFromMapFor(mapKey, key2) ?? false;
    if (removed && (_mapChar?.isEmpty ?? false)) _mapChar = null;
    return removed;
  }

  Set<MapKey<dynamic, dynamic>> getMapKeys() =>
      _mapChar == null ? {} : _mapChar!.getKeySet();

  int getSafeSizeOfMapFor(MapKey<dynamic, dynamic> mapKey) {
    if (_mapChar == null || !_mapChar!.containsMapFor(mapKey)) return 0;
    return _mapChar!.getKeysFor(mapKey).length;
  }

  // --- Identified / Loadable implementation ---

  @override
  String getKeyName() {
    return get(StringKey.keyName) ?? getDisplayName();
  }

  void setKeyName(String key) {
    putString(StringKey.keyName, key);
  }

  @override
  String getDisplayName() => _displayName;

  void setDisplayName(String name) {
    _displayName = name;
  }

  @override
  void setName(String name) {
    setDisplayName(name);
  }

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) {
    _sourceURI = source;
  }

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  // --- PCGenScoped ---
  @override
  String? getScopeName() => null;

  @override
  PCGenScoped? getEnclosingScope() => null;

  // --- Equality ---

  bool isCDOMEqual(CDOMObject cdo) {
    if (identical(this, cdo)) return true;
    if (!equalsPrereqObject(cdo)) return false;
    if (_integerChar != cdo._integerChar) {
      if (_integerChar == null || cdo._integerChar == null) return false;
      if (_integerChar!.length != cdo._integerChar!.length) return false;
    }
    if (_stringChar != cdo._stringChar) {
      if (_stringChar == null || cdo._stringChar == null) return false;
      if (_stringChar!.length != cdo._stringChar!.length) return false;
    }
    return true;
  }
}

// Import for LinkedHashSet
class LinkedHashSet<T> extends Set<T> {
  final Set<T> _inner = {};

  LinkedHashSet.from(Iterable<T> items) {
    _inner.addAll(items);
  }

  @override
  bool add(T value) => _inner.add(value);
  @override
  bool contains(Object? element) => _inner.contains(element);
  @override
  Iterator<T> get iterator => _inner.iterator;
  @override
  int get length => _inner.length;
  @override
  T? lookup(Object? element) => _inner.lookup(element);
  @override
  bool remove(Object? value) => _inner.remove(value);
  @override
  Set<T> toSet() => Set.from(_inner);
}
