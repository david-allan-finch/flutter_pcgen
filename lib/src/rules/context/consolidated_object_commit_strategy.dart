//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.rules.context.ConsolidatedObjectCommitStrategy
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
import 'map_changes.dart';
import 'object_commit_strategy.dart';
import 'pattern_changes.dart';

// Commit strategy that applies changes directly to CDOMObjects.
class ConsolidatedObjectCommitStrategy implements ObjectCommitStrategy {
  String sourceURI = '';
  String extractURI = '';

  @override
  void setSourceURI(String uri) => sourceURI = uri;

  @override
  void setExtractURI(String uri) => extractURI = uri;

  @override
  String? getString(CDOMObject cdo, StringKey sk) => cdo.get(sk) as String?;

  @override
  int? getInteger(CDOMObject cdo, IntegerKey ik) => cdo.get(ik) as int?;

  @override
  dynamic getFormula(CDOMObject cdo, FormulaKey fk) => cdo.get(fk);

  @override
  dynamic getVariable(CDOMObject obj, VariableKey key) => obj.get(key);

  @override
  Set<VariableKey> getVariableKeys(CDOMObject obj) => obj.getVariableKeys();

  @override
  dynamic getObject(CDOMObject cdo, ObjectKey<dynamic> ik) => cdo.get(ik);

  @override
  dynamic getFact(CDOMObject cdo, FactKey<dynamic> ik) => cdo.get(ik);

  @override
  Changes<dynamic> getSetChanges(CDOMObject cdo, FactSetKey<dynamic> lk) =>
      CollectionChanges(cdo.getSetFor(lk), null, false);

  @override
  Changes<dynamic> getListChanges(CDOMObject cdo, ListKey<dynamic> lk) =>
      CollectionChanges(cdo.getListFor(lk), null, false);

  @override
  void putString(CDOMObject cdo, StringKey sk, String s) => cdo.put(sk, s);

  @override
  void putObject<T>(CDOMObject cdo, ObjectKey<T> sk, T s) => cdo.put(sk, s);

  @override
  void removeObject(CDOMObject cdo, ObjectKey<dynamic> sk) => cdo.remove(sk);

  @override
  void putFact<T>(CDOMObject cdo, FactKey<T> sk, dynamic s) =>
      cdo.put(sk, s);

  @override
  void removeFact(CDOMObject cdo, FactKey<dynamic> sk) => cdo.remove(sk);

  @override
  void putInteger(CDOMObject cdo, IntegerKey ik, int i) => cdo.put(ik, i);

  @override
  void putFormula(CDOMObject cdo, FormulaKey fk, dynamic f) => cdo.put(fk, f);

  @override
  void putVariable(CDOMObject obj, VariableKey vk, dynamic f) => obj.put(vk, f);

  @override
  bool containsListFor(CDOMObject cdo, ListKey<dynamic> key) =>
      cdo.containsListFor(key);

  @override
  void addToList<T>(CDOMObject cdo, ListKey<T> key, T value) =>
      cdo.addToListFor(key, value);

  @override
  void removeList(CDOMObject cdo, ListKey<dynamic> lk) =>
      cdo.removeListFor(lk);

  @override
  void removeFromList<T>(CDOMObject cdo, ListKey<T> lk, T val) =>
      cdo.removeFromListFor(lk, val);

  @override
  bool containsSetFor(CDOMObject cdo, FactSetKey<dynamic> key) =>
      cdo.containsSetFor(key);

  @override
  void addToSet<T>(CDOMObject cdo, FactSetKey<T> key, dynamic value) =>
      cdo.addToSetFor(key, value);

  @override
  void removeSet(CDOMObject cdo, FactSetKey<dynamic> lk) =>
      cdo.removeSetFor(lk);

  @override
  void removeFromSet<T>(CDOMObject cdo, FactSetKey<T> lk, dynamic val) =>
      cdo.removeFromSetFor(lk, val);

  @override
  void putMap<K, V>(CDOMObject cdo, MapKey<K, V> mk, K key, V value) =>
      cdo.addToMapFor(mk, key, value);

  @override
  void removeFromMap<K, V>(CDOMObject cdo, MapKey<K, V> mk, K key) =>
      cdo.removeFromMapFor(mk, key);

  @override
  void putPrereq(ConcretePrereqObject cpo, dynamic p) =>
      cpo.addPrerequisite(p);

  @override
  MapChanges<K, V> getMapChanges<K, V>(CDOMObject cdo, MapKey<K, V> mk) =>
      MapChanges(cdo.getMapFor(mk), null, false);

  @override
  Changes<dynamic> getPrerequisiteChanges(ConcretePrereqObject obj) =>
      CollectionChanges(obj.getPrerequisiteList(), null, false);

  @override
  void removePatternFromList<T>(CDOMObject cdo, ListKey<T> lk, String pattern) {
    final list = cdo.getListFor(lk);
    if (list == null || list.isEmpty) return;
    final regex = RegExp(pattern);
    for (final obj in List.from(list)) {
      if (regex.hasMatch(obj.toString())) {
        cdo.removeFromListFor(lk, obj as T);
      }
    }
  }

  @override
  void clearPrerequisiteList(ConcretePrereqObject cpo) =>
      cpo.clearPrerequisiteList();

  @override
  PatternChanges<dynamic> getListPatternChanges(
          CDOMObject cdo, ListKey<dynamic> lk) =>
      PatternChanges(cdo.getListFor(lk), null, false);

  // wasRemoved always returns false for consolidated (non-tracking) strategy
  @override
  bool wasRemovedObject(CDOMObject cdo, ObjectKey<dynamic> ok) => false;

  @override
  bool wasRemovedFact(CDOMObject cdo, FactKey<dynamic> ok) => false;

  @override
  bool wasRemovedFactSet(CDOMObject cdo, FactSetKey<dynamic> ok) => false;

  @override
  void removeString(CDOMObject cdo, StringKey sk) => cdo.remove(sk);

  @override
  bool wasRemovedString(CDOMObject cdo, StringKey sk) => false;

  @override
  void removeInteger(CDOMObject cdo, IntegerKey ik) => cdo.remove(ik);

  @override
  bool wasRemovedInteger(CDOMObject cdo, IntegerKey ik) => false;
}
