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
// Translation of pcgen.rules.context.ObjectCommitStrategy
import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/fact_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/fact_set_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/formula_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/map_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/variable_key.dart';
import 'package:flutter_pcgen/src/rules/context/changes.dart';
import 'package:flutter_pcgen/src/rules/context/map_changes.dart';
import 'package:flutter_pcgen/src/rules/context/pattern_changes.dart';

abstract interface class ObjectCommitStrategy {
  void putString(CDOMObject cdo, StringKey sk, String s);

  void removeString(CDOMObject cdo, StringKey sk);

  void putObject<T>(CDOMObject cdo, CDOMObjectKey<T> sk, T s);

  void removeObject(CDOMObject cdo, CDOMObjectKey<dynamic> sk);

  void putFact<T>(CDOMObject cdo, FactKey<T> sk, Indirect<T> s);

  void removeFact(CDOMObject cdo, FactKey<dynamic> sk);

  void putInteger(CDOMObject cdo, IntegerKey ik, int i);

  void removeInteger(CDOMObject cdo, IntegerKey ik);

  // Formula is represented as dynamic (unresolved dependency)
  void putFormula(CDOMObject cdo, FormulaKey fk, dynamic f);

  void putVariable(CDOMObject obj, VariableKey vk, dynamic f);

  void addToList<T>(CDOMObject cdo, ListKey<T> key, T value);

  void removeList(CDOMObject cdo, ListKey<dynamic> lk);

  void removeFromList<T>(CDOMObject cdo, ListKey<T> lk, T val);

  void addToSet<T>(CDOMObject cdo, FactSetKey<T> key, Indirect<T> value);

  void removeSet(CDOMObject cdo, FactSetKey<dynamic> lk);

  void removeFromSet<T>(CDOMObject cdo, FactSetKey<T> lk, Indirect<T> val);

  int? getInteger(CDOMObject cdo, IntegerKey ik);

  dynamic getFormula(CDOMObject cdo, FormulaKey fk);

  dynamic getVariable(CDOMObject obj, VariableKey key);

  Set<VariableKey> getVariableKeys(CDOMObject obj);

  T? getObject<T>(CDOMObject cdo, CDOMObjectKey<T> ik);

  Indirect<T>? getFact<T>(CDOMObject cdo, FactKey<T> ik);

  Changes<T> getListChanges<T>(CDOMObject cdo, ListKey<T> lk);

  Changes<Indirect<T>> getSetChanges<T>(CDOMObject cdo, FactSetKey<T> lk);

  void putMap<K, V>(CDOMObject cdo, MapKey<K, V> mk, K key, V value);

  void removeMap<K, V>(CDOMObject cdo, MapKey<K, V> mk, K key);

  MapChanges<K, V> getMapChanges<K, V>(CDOMObject cdo, MapKey<K, V> mk);

  void setExtractURI(String? extractURI);

  void setSourceURI(String? sourceURI);

  void putPrerequisite(ConcretePrereqObject cpo, dynamic p);

  Changes<dynamic> getPrerequisiteChanges(ConcretePrereqObject obj);

  String? getString(CDOMObject cdo, StringKey sk);

  bool containsListFor(CDOMObject obj, ListKey<dynamic> lk);

  bool containsSetFor(CDOMObject obj, FactSetKey<dynamic> lk);

  void removePatternFromList<T>(CDOMObject cdo, ListKey<T> lk, String pattern);

  void clearPrerequisiteList(ConcretePrereqObject cpo);

  PatternChanges<T> getListPatternChanges<T>(CDOMObject cdo, ListKey<T> lk);

  bool wasRemovedObject(CDOMObject cdo, CDOMObjectKey<dynamic> ok);

  bool wasRemovedFact(CDOMObject cdo, FactKey<dynamic> ok);

  bool wasRemovedFactSet(CDOMObject cdo, FactSetKey<dynamic> ok);

  bool wasRemovedInteger(CDOMObject cdo, IntegerKey ik);

  bool wasRemovedString(CDOMObject cdo, StringKey sk);
}
