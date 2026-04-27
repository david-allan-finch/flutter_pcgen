// Translation of pcgen.rules.context.RuntimeLoadContext
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net> - LGPL 2.1+
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License v2.1+.

import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/group_definition.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/base/primitive_collection.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/data_set_id.dart';
import 'package:flutter_pcgen/src/cdom/reference/reference_manufacturer.dart';
import 'package:flutter_pcgen/src/cdom/reference/selection_creator.dart';
import 'package:flutter_pcgen/src/formula/inst/nep_formula.dart';
import 'package:flutter_pcgen/src/rules/context/abstract_list_context.dart';
import 'package:flutter_pcgen/src/rules/context/abstract_object_context.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/rules/context/runtime_reference_context.dart';
import 'package:flutter_pcgen/src/rules/context/variable_context.dart';

/// Concrete [LoadContext] used during data loading.
///
/// Backed by [RuntimeReferenceContext] which provides a real keyed object
/// registry.  Methods not needed by the current loading pipeline are stubbed.
class RuntimeLoadContext implements LoadContext {
  final RuntimeReferenceContext _ref = RuntimeReferenceContext();
  final DataSetID _datasetID = DataSetID.generate();
  String? _sourceURI;
  final List<dynamic> _campaigns = [];

  @override
  RuntimeReferenceContext getReferenceContext() => _ref;

  @override
  void setSourceURI(String? uri) => _sourceURI = uri;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setExtractURI(String? extractURI) {}

  @override
  DataSetID getDataSetID() => _datasetID;

  // ---- sub-context accessors (stubs) ----
  @override
  AbstractReferenceContext getObjectContext() =>
      throw UnimplementedError('getObjectContext');

  @override
  AbstractListContext getListContext() =>
      throw UnimplementedError('getListContext');

  @override
  VariableContext getVariableContext() =>
      throw UnimplementedError('getVariableContext');

  // ---- commit / rollback ----
  @override
  void commit() {}

  @override
  void rollback() {}

  // ---- deferred token resolution ----
  @override
  void resolveDeferredTokens() {}

  @override
  void resolvePostDeferredTokens() {}

  @override
  void resolvePostValidationTokens() {}

  // ---- choice helpers ----
  @override
  PrimitiveCollection<T>? getChoiceSet<T extends CDOMObject>(
          SelectionCreator<T> sc, String value) =>
      null;

  @override
  PrimitiveCollection<T>? getPrimitiveChoiceFilter<T extends CDOMObject>(
          SelectionCreator<T> sc, String key) =>
      null;

  // ---- prerequisite string ----
  @override
  String? getPrerequisiteString(List<dynamic> prereqs) => null;

  // ---- reference manufacturer ----
  @override
  ReferenceManufacturer<dynamic>? getManufacturer(String firstToken) => null;

  // ---- forgetMeNot ----
  @override
  void forgetMeNot(CDOMReference<dynamic> cdr) {}

  // ---- CDOMObject operations ----
  @override
  T cloneConstructedCDOMObject<T extends CDOMObject>(T cdo, String newName) =>
      cdo;

  @override
  T performCopy<T extends CDOMObject>(T object, String copyName) => object;

  // ---- campaign source entry ----
  @override
  dynamic getCampaignSourceEntry(dynamic source, String value) => null;

  // ---- stateful information ----
  @override
  void clearStatefulInformation() {}

  @override
  bool addStatefulToken(String s) => false;

  @override
  void addStatefulInformation(CDOMObject target) {}

  // ---- campaign list ----
  @override
  void setLoaded(List<dynamic> campaigns) {
    _campaigns
      ..clear()
      ..addAll(campaigns);
  }

  @override
  List<dynamic> getLoadedCampaigns() => List.unmodifiable(_campaigns);

  // ---- facet initialization ----
  @override
  void loadCampaignFacets() {}

  // ---- consolidate ----
  @override
  bool consolidate() => true;

  // ---- token processing ----
  @override
  dynamic processSubToken<T>(
          T cdo, String tokenName, String key, String value) =>
      null;

  @override
  bool processToken<T extends Loadable>(
          T derivative, String typeStr, String argument) =>
      false;

  @override
  void unconditionallyProcess<T extends Loadable>(
      T cdo, String key, String value) {}

  // ---- unparse ----
  @override
  List<String> unparseSubtoken<T>(T cdo, String tokenName) => const [];

  @override
  List<String> unparse<T extends Loadable>(T cdo) => const [];

  // ---- write message tracking ----
  @override
  void addWriteMessage(String string) => print('WRITE: $string');

  @override
  int getWriteMessageCount() => 0;

  // ---- scope navigation ----
  @override
  dynamic getActiveScope() => null;

  @override
  LoadContext dropIntoContext(String scope) => this;

  // ---- token loading ----
  @override
  void loadLocalToken(Object token) {}

  // ---- group support ----
  @override
  GroupDefinition<T>? getGroup<T>(Type cl, String s) => null;

  // ---- deferred method controllers ----
  @override
  void addDeferredMethodController(dynamic commitTask) {}

  // ---- formula evaluation ----
  @override
  NEPFormula<T> getValidFormula<T>(
          FormatManager<T> formatManager, String instructions) =>
      throw UnimplementedError('getValidFormula');

  // ---- grouping ----
  @override
  dynamic getGrouping(dynamic scope, String groupingName) => null;
}
