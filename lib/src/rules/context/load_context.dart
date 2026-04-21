// Translated from pcgen/rules/context/LoadContext.java
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net> - LGPL 2.1+
//
// Full LoadContext interface matching the Java original. The original thin
// stub has been replaced by this complete translation so that LoadContextInst
// can implement it faithfully.

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
import 'abstract_list_context.dart';
import 'abstract_object_context.dart';
import 'runtime_reference_context.dart' show AbstractReferenceContext;
import 'variable_context.dart';

// ---------------------------------------------------------------------------
// Shared stub types referenced by LoadContext and LoadContextInst
// ---------------------------------------------------------------------------

// stub: Campaign — represents a loaded campaign; full class in pcgen.core
class Campaign extends CDOMObject {
  @override
  bool isType(String type) => false;
}

// stub: CampaignSourceEntry — source entry within a campaign
class CampaignSourceEntry {
  // stub: getNewCSE is defined in LoadContextInst with access to sourceURI
}

// stub: Prerequisite — represents a PRExxx prerequisite
class Prerequisite {}

// stub: ParseResult — result of parsing a token line
class ParseResult {
  final bool _passed;
  const ParseResult._(this._passed);
  static const ParseResult pass = ParseResult._(true);
  static const ParseResult fail = ParseResult._(false);
  bool get passed => _passed;
}

// stub: DeferredMethodController — records a method invocation to run at commit time
class DeferredMethodController {
  final void Function() _task;
  const DeferredMethodController(this._task);
  void run() => _task();
}

// ---------------------------------------------------------------------------
// LoadContext — full interface
// ---------------------------------------------------------------------------

/// The full LoadContext interface.
///
/// Provides all operations needed during data loading: reference management,
/// token processing, scope navigation, formula evaluation, and commit/rollback.
abstract interface class LoadContext {
  // ---- URI management ----

  void setExtractURI(String? extractURI);
  void setSourceURI(String? sourceURI);
  String? getSourceURI();

  // ---- data set identity ----

  DataSetID getDataSetID();

  // ---- sub-context accessors ----

  AbstractReferenceContext getReferenceContext();
  AbstractObjectContext getObjectContext();
  AbstractListContext getListContext();
  VariableContext getVariableContext();

  // ---- commit / rollback ----

  void commit();
  void rollback();

  // ---- deferred / post-deferred / post-validation token resolution ----

  void resolveDeferredTokens();
  void resolvePostDeferredTokens();
  void resolvePostValidationTokens();

  // ---- choice set helpers ----

  PrimitiveCollection<T>? getChoiceSet<T extends CDOMObject>(
      SelectionCreator<T> sc, String value);

  PrimitiveCollection<T>? getPrimitiveChoiceFilter<T extends CDOMObject>(
      SelectionCreator<T> sc, String key);

  // ---- prerequisite string ----

  String? getPrerequisiteString(List<Prerequisite> prereqs);

  // ---- reference manufacturer ----

  ReferenceManufacturer<dynamic>? getManufacturer(String firstToken);

  // ---- forgetMeNot ----

  void forgetMeNot(CDOMReference<dynamic> cdr);

  // ---- CDOMObject cloning ----

  T cloneConstructedCDOMObject<T extends CDOMObject>(T cdo, String newName);

  // ---- copy ----

  T performCopy<T extends CDOMObject>(T object, String copyName);

  // ---- campaign source entry ----

  CampaignSourceEntry? getCampaignSourceEntry(Campaign source, String value);

  // ---- stateful information ----

  void clearStatefulInformation();
  bool addStatefulToken(String s);
  void addStatefulInformation(CDOMObject target);

  // ---- campaign list ----

  void setLoaded(List<Campaign> campaigns);
  List<Campaign> getLoadedCampaigns();

  // ---- facet initialization ----

  void loadCampaignFacets();

  // ---- consolidate ----

  bool consolidate();

  // ---- token processing ----

  ParseResult processSubToken<T>(
      T cdo, String tokenName, String key, String value);

  bool processToken<T extends Loadable>(
      T derivative, String typeStr, String argument);

  void unconditionallyProcess<T extends Loadable>(
      T cdo, String key, String value);

  // ---- unparse ----

  List<String> unparseSubtoken<T>(T cdo, String tokenName);

  List<String> unparse<T extends Loadable>(T cdo);

  // ---- write message tracking ----

  void addWriteMessage(String string);
  int getWriteMessageCount();

  // ---- scope navigation ----

  /// Returns the currently active PCGenScope (as dynamic until fully translated).
  dynamic getActiveScope();

  LoadContext dropIntoContext(String scope);

  // ---- token loading ----

  void loadLocalToken(Object token);

  // ---- group support ----

  GroupDefinition<T>? getGroup<T>(Type cl, String s);

  // ---- deferred method controllers ----

  void addDeferredMethodController(DeferredMethodController commitTask);

  // ---- formula evaluation ----

  NEPFormula<T> getValidFormula<T>(
      FormatManager<T> formatManager, String instructions);

  // ---- grouping ----

  /// Returns a GroupingCollection for the given scope and grouping name.
  /// Return type is dynamic until GroupingCollection is translated.
  dynamic getGrouping(dynamic scope, String groupingName);
}
