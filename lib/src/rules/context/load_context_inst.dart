// Translated from pcgen/rules/context/LoadContextInst.java
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net> - LGPL 2.1+

import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/group_definition.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/base/primitive_collection.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/data_set_id.dart';
import 'package:flutter_pcgen/src/cdom/inst/object_cache.dart';
import 'package:flutter_pcgen/src/cdom/reference/reference_manufacturer.dart';
import 'package:flutter_pcgen/src/cdom/reference/selection_creator.dart';
import 'package:flutter_pcgen/src/formula/inst/nep_formula.dart';
import 'package:flutter_pcgen/src/rules/context/abstract_list_context.dart';
import 'package:flutter_pcgen/src/rules/context/abstract_object_context.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/rules/context/pcgen_manager_factory.dart';
import 'package:flutter_pcgen/src/rules/context/reference_context_utilities.dart';
import 'runtime_reference_context.dart' show AbstractReferenceContext;
import 'package:flutter_pcgen/src/rules/context/variable_context.dart';

// ---------------------------------------------------------------------------
// Stubs for types not yet fully translated
// ---------------------------------------------------------------------------

// stub: TokenSupport — wraps token processing logic
class TokenSupport {
  // stub: real implementation delegates to token registry
  dynamic processSubToken(LoadContext ctx, dynamic cdo, String tokenName,
      String key, String value) =>
      null; // stub

  bool processToken(LoadContext ctx, dynamic derivative, String typeStr,
      String argument) =>
      false; // stub

  List<String> unparseSubtoken(LoadContext ctx, dynamic cdo,
      String tokenName) =>
      const []; // stub

  List<String> unparse(LoadContext ctx, dynamic cdo) =>
      const []; // stub

  void loadLocalToken(Object token) {} // stub

  GroupDefinition<T>? getGroup<T>(Type cl, String s) => null; // stub

  List<dynamic> getDeferredTokens() => const []; // stub
}

// stub: DeferredToken — runs deferred processing after all tokens are loaded
abstract interface class DeferredToken<T extends Loadable> {
  Type getDeferredTokenClass();
  void process(LoadContext context, T obj);
}

// stub: PostDeferredToken
abstract interface class PostDeferredToken<T extends Loadable> {
  Type getDeferredTokenClass();
  void process(LoadContext context, T obj);
}

// stub: PostValidationToken
abstract interface class PostValidationToken<T extends Loadable> {
  Type getValidationTokenClass();
  void process(LoadContext context, List<T> objects);
}

// stub: TokenLibrary
class TokenLibrary {
  static List<PostDeferredToken<dynamic>> getPostDeferredTokens() =>
      const []; // stub

  static List<PostValidationToken<dynamic>> getPostValidationTokens() =>
      const []; // stub
}

// stub: ParseResult — result of parsing a token
class ParseResult {
  final bool _passed;
  const ParseResult._(this._passed);
  static const ParseResult pass = ParseResult._(true);
  static const ParseResult fail = ParseResult._(false);
  bool get passed => _passed;
}

// stub: Campaign — represents a campaign source
class Campaign extends CDOMObject {
  @override
  bool isType(String type) => false;
}

// stub: CampaignSourceEntry
class CampaignSourceEntry {
  static CampaignSourceEntry? getNewCSE(
      Campaign source, String? sourceURI, String value) =>
      null; // stub
}

// stub: Prerequisite
class Prerequisite {}

// stub: PrerequisiteWriter
class PrerequisiteWriter {
  String getPrerequisiteString(List<Prerequisite> prereqs) =>
      ''; // stub
}

// stub: ChoiceSetLoadUtilities
class ChoiceSetLoadUtilities {
  static PrimitiveCollection<T>? getChoiceSet<T extends CDOMObject>(
      LoadContext ctx, SelectionCreator<T> sc, String value) =>
      null; // stub

  static PrimitiveCollection<T>? getPrimitive<T extends CDOMObject>(
      LoadContext ctx, SelectionCreator<T> sc, String key) =>
      null; // stub

  static dynamic getDynamicGroup(LoadContext ctx, dynamic info) =>
      null; // stub
}

// stub: DeferredMethodController — records a method invocation to run later
class DeferredMethodController {
  final void Function() _task;
  const DeferredMethodController(this._task);
  void run() => _task();
}

// stub: GroupingInfo / GroupingInfoFactory
class GroupingInfo {
  final dynamic scope;
  final String name;
  GroupingInfo(this.scope, this.name);
}

class GroupingStateException implements Exception {
  final String message;
  GroupingStateException(this.message);
}

class GroupingInfoFactory {
  GroupingInfo process(dynamic scope, String groupingName) {
    // stub
    return GroupingInfo(scope, groupingName);
  }
}

// stub: GlobalPCScope
class GlobalPCScope {
  static const String globalScopeName = 'PC';
}

// stub: FacetInitialization
class FacetInitialization {
  static void initialize() {} // stub
}

// stub: FacetLibrary / DataSetInitializationFacet
class DataSetInitializationFacet {
  void initialize(LoadContextInst ctx) {} // stub
}

class FacetLibrary {
  static T getFacet<T>(Type cl) {
    if (cl == DataSetInitializationFacet) {
      return DataSetInitializationFacet() as T;
    }
    throw UnimplementedError('FacetLibrary.getFacet: $cl not yet translated');
  }
}

// ---------------------------------------------------------------------------
// LoadContext — full interface (replaces the thin stub in load_context.dart)
// ---------------------------------------------------------------------------
//
// Rather than re-declare a separate interface, LoadContextInst (below) directly
// implements the same contract. The thin load_context.dart is kept for
// back-compat but the canonical API lives here.

// ---------------------------------------------------------------------------
// LoadContextInst
// ---------------------------------------------------------------------------

/// Abstract base for a loading context (both Editor and Runtime variants).
///
/// Translated from Java's package-private abstract class LoadContextInst.
/// All method logic is preserved; only Java-specific idioms (reflection,
/// static initializers, weak references) are stubbed.
abstract class LoadContextInst implements LoadContext {
  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  static final PrerequisiteWriter _prereqWriter = PrerequisiteWriter();

  final DataSetID datasetID = DataSetID.generate();

  final AbstractListContext _list;
  final AbstractObjectContext _obj;
  final AbstractReferenceContext _ref;
  final VariableContext _var;

  final List<Campaign> _campaignList = [];

  int _writeMessageCount = 0;

  final TokenSupport _support = TokenSupport();

  /// Holds CDOMReferences that should not be garbage-collected.
  final List<Object> _dontForget = [];

  /// Deferred method controllers to run at commit time.
  final List<DeferredMethodController> _commitTasks = [];

  // Per-file state
  String? _sourceURI;
  CDOMObject? _stateful;

  // Current scope
  dynamic _legalScope; // PCGenScope — dynamic until fully translated

  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  LoadContextInst(AbstractReferenceContext rc, AbstractListContext lc,
      AbstractObjectContext oc)
      : _ref = rc,
        _list = lc,
        _obj = oc,
        _var = VariableContext(null) {
    // Note: VariableContext is constructed with a PCGenManagerFactory in Java.
    // We pass null here because PCGenManagerFactory's constructor needs `this`
    // (a LoadContextInst), which is not yet fully initialised.  The field
    // is set via a post-construction hook that subclasses should call if they
    // need real formula evaluation.
    //
    // stub: FacetInitialization.initialize() called in Java static block
    FacetInitialization.initialize();
  }

  /// Factory-style constructor that wires PCGenManagerFactory correctly.
  /// Subclasses should call this via a two-step pattern if needed.
  /// stub: two-step init not expressible in Dart constructors; left as comment.

  // ---------------------------------------------------------------------------
  // LoadContext — write message tracking
  // ---------------------------------------------------------------------------

  @override
  void addWriteMessage(String string) {
    print('!!$string');
    // TODO: find a better solution for what happens during write
    _writeMessageCount++;
  }

  @override
  int getWriteMessageCount() => _writeMessageCount;

  // ---------------------------------------------------------------------------
  // LoadContext — URI management
  // ---------------------------------------------------------------------------

  /// Sets the extract URI on all sub-contexts.
  @override
  void setExtractURI(String? extractURI) {
    getObjectContext().setExtractURI(extractURI);
    getReferenceContext().setExtractURI(extractURI); // stub: method may not exist yet
    getListContext().setExtractURI(extractURI);
  }

  /// Sets the source URI on all sub-contexts and clears stateful information.
  @override
  void setSourceURI(String? sourceURI) {
    _sourceURI = sourceURI;
    getObjectContext().setSourceURI(sourceURI);
    getReferenceContext().setSourceURI(sourceURI); // stub: method may not exist yet
    getListContext().setSourceURI(sourceURI);
    clearStatefulInformation();
    // stub: LOG.log(Level.FINER, "Starting Load of " + sourceURI)
    // print('Starting Load of $sourceURI');
  }

  @override
  String? getSourceURI() => _sourceURI;

  // ---------------------------------------------------------------------------
  // LoadContext — context type (abstract)
  // ---------------------------------------------------------------------------

  /// Returns the type of context ('Editor' or 'Runtime').
  String getContextType();

  // ---------------------------------------------------------------------------
  // LoadContext — sub-context accessors
  // ---------------------------------------------------------------------------

  @override
  AbstractObjectContext getObjectContext() => _obj;

  @override
  AbstractListContext getListContext() => _list;

  @override
  VariableContext getVariableContext() => _var;

  @override
  AbstractReferenceContext getReferenceContext() => _ref;

  // ---------------------------------------------------------------------------
  // LoadContext — commit / rollback
  // ---------------------------------------------------------------------------

  @override
  void commit() {
    getListContext().commit();
    getObjectContext().commit();
    for (final task in _commitTasks) {
      task.run();
    }
    _commitTasks.clear();
  }

  @override
  void rollback() {
    getListContext().rollback();
    getObjectContext().rollback();
    _commitTasks.clear();
  }

  // ---------------------------------------------------------------------------
  // LoadContext — deferred / post-deferred / post-validation token processing
  // ---------------------------------------------------------------------------

  @override
  void resolveDeferredTokens() {
    for (final token in _support.getDeferredTokens()) {
      _processRes(token as DeferredToken<Loadable>);
    }
    commit();
  }

  void _processRes<T extends Loadable>(DeferredToken<T> token) {
    final cl = token.getDeferredTokenClass();
    final mfgs = getReferenceContext().getAllManufacturers();
    for (final rm in mfgs) {
      // stub: isAssignableFrom checked via Type equality (simplified)
      if (rm.getReferenceClass() == cl ||
          _isAssignableFrom(cl, rm.getReferenceClass())) {
        final objects = rm.getAllObjects() as List<T>;
        for (final po in objects) {
          token.process(this, po);
        }
        // stub: getDerivativeObjects — not all manufacturers support this yet
        final derivative = _getDerivativeObjects<T>(rm);
        for (final po in derivative) {
          token.process(this, po);
        }
      }
    }
  }

  // stub: real isAssignableFrom uses Java reflection
  bool _isAssignableFrom(Type supertype, dynamic subtype) => false; // stub

  // stub: getDerivativeObjects on ReferenceManufacturer not yet translated
  List<T> _getDerivativeObjects<T extends Loadable>(
      ReferenceManufacturer<dynamic> rm) =>
      const []; // stub

  @override
  void resolvePostDeferredTokens() {
    final mfgs = getReferenceContext().getAllManufacturers();
    for (final token in TokenLibrary.getPostDeferredTokens()) {
      _processPostRes(token as PostDeferredToken<Loadable>, mfgs);
    }
  }

  void _processPostRes<T extends Loadable>(PostDeferredToken<T> token,
      List<ReferenceManufacturer<dynamic>> mfgs) {
    final cl = token.getDeferredTokenClass();
    for (final rm in mfgs) {
      if (rm.getReferenceClass() == cl ||
          _isAssignableFrom(cl, rm.getReferenceClass())) {
        final objects = rm.getAllObjects() as List<T>;
        for (final po in objects) {
          setSourceURI(po.getSourceURI());
          token.process(this, po);
        }
      }
    }
  }

  @override
  void resolvePostValidationTokens() {
    final mfgs = getReferenceContext().getAllManufacturers();
    for (final token in TokenLibrary.getPostValidationTokens()) {
      _processPostVal(token as PostValidationToken<Loadable>, mfgs);
    }
  }

  void _processPostVal<T extends Loadable>(PostValidationToken<T> token,
      List<ReferenceManufacturer<dynamic>> mfgs) {
    final cl = token.getValidationTokenClass();
    for (final rm in mfgs) {
      if (rm.getReferenceClass() == cl ||
          _isAssignableFrom(cl, rm.getReferenceClass())) {
        setSourceURI(null);
        final objects = rm.getAllObjects() as List<T>;
        token.process(this, objects);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // LoadContext — choice set helpers
  // ---------------------------------------------------------------------------

  @override
  PrimitiveCollection<T>? getChoiceSet<T extends CDOMObject>(
      SelectionCreator<T> sc, String value) {
    try {
      return ChoiceSetLoadUtilities.getChoiceSet(this, sc, value);
    } on GroupingStateException catch (e) {
      print('Group Mismatch in getting ChoiceSet: ${e.message}');
      return null;
    }
    // stub: ParsingSeparator.GroupingMismatchException mapped to
    //       GroupingStateException above
  }

  @override
  PrimitiveCollection<T>? getPrimitiveChoiceFilter<T extends CDOMObject>(
      SelectionCreator<T> sc, String key) {
    return ChoiceSetLoadUtilities.getPrimitive(this, sc, key);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — token processing
  // ---------------------------------------------------------------------------

  @override
  ParseResult processSubToken<T>(
      T cdo, String tokenName, String key, String value) {
    return _support.processSubToken(this, cdo, tokenName, key, value)
        as ParseResult? ??
        ParseResult.fail;
  }

  @override
  bool processToken<T extends Loadable>(
      T derivative, String typeStr, String argument) {
    return _support.processToken(this, derivative, typeStr, argument);
  }

  @override
  void unconditionallyProcess<T extends Loadable>(
      T cdo, String key, String value) {
    if (processToken(cdo, key, value)) {
      commit();
    } else {
      rollback();
      // stub: Logging.replayParsedMessages()
    }
    // stub: Logging.clearParseMessages()
  }

  // ---------------------------------------------------------------------------
  // LoadContext — unparse / token unparsing
  // ---------------------------------------------------------------------------

  /// Produce the LST code for any occurrences of subtokens of the parent token.
  @override
  List<String> unparseSubtoken<T>(T cdo, String tokenName) {
    return _support.unparseSubtoken(this, cdo, tokenName);
  }

  @override
  List<String> unparse<T extends Loadable>(T cdo) {
    return _support.unparse(this, cdo);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — CDOMObject cloning
  // ---------------------------------------------------------------------------

  @override
  T cloneConstructedCDOMObject<T extends CDOMObject>(T cdo, String newName) {
    final newObj = getObjectContext().cloneConstructedCDOMObject(cdo, newName) as T;
    getReferenceContext().importObject(newObj);
    return newObj;
  }

  /// Create a copy of a CDOMObject duplicating any references to the old object.
  /// Package-internal visibility in Java; exposed here for testing.
  T? cloneInMasterLists<T extends CDOMObject>(T cdo, String newName) {
    try {
      // stub: Java used cdo.clone() via reflection
      // Dart callers must provide their own clone logic.
      final T? newObj = _cloneObject(cdo, newName); // stub
      if (newObj == null) return null;
      newObj.setName(newName);
      getListContext().cloneInMasterLists(cdo, newObj);
      return newObj;
    } catch (e) {
      print('Failed to clone $cdo: $e');
      return null;
    }
  }

  // stub: CDOMObject cloning is not generically available in Dart
  T? _cloneObject<T extends CDOMObject>(T cdo, String newName) => null; // stub

  // ---------------------------------------------------------------------------
  // LoadContext — prerequisite string
  // ---------------------------------------------------------------------------

  @override
  String? getPrerequisiteString(List<Prerequisite> prereqs) {
    try {
      return _prereqWriter.getPrerequisiteString(prereqs);
    } catch (e) {
      addWriteMessage('Error writing Prerequisite: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // LoadContext — campaign source entry
  // ---------------------------------------------------------------------------

  @override
  CampaignSourceEntry? getCampaignSourceEntry(Campaign source, String value) {
    return CampaignSourceEntry.getNewCSE(source, _sourceURI, value);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — stateful token support
  // ---------------------------------------------------------------------------

  @override
  void clearStatefulInformation() {
    _stateful = null;
  }

  @override
  bool addStatefulToken(String s) {
    final colonLoc = s.indexOf(':');
    if (colonLoc == -1) {
      print('Found invalid stateful token: $s');
      return false;
    }
    _stateful ??= ObjectCache();
    return processToken(
        _stateful!, s.substring(0, colonLoc), s.substring(colonLoc + 1));
  }

  @override
  void addStatefulInformation(CDOMObject target) {
    if (_stateful != null) {
      target.overlayCDOMObject(_stateful!);
    }
  }

  // ---------------------------------------------------------------------------
  // LoadContext — campaign list
  // ---------------------------------------------------------------------------

  @override
  void setLoaded(List<Campaign> campaigns) {
    _campaignList.clear();
    _campaignList.addAll(campaigns);
  }

  @override
  List<Campaign> getLoadedCampaigns() {
    return List.unmodifiable(_campaignList);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — consolidate (abstract)
  // ---------------------------------------------------------------------------

  @override
  bool consolidate();

  // ---------------------------------------------------------------------------
  // LoadContext — data set ID
  // ---------------------------------------------------------------------------

  @override
  DataSetID getDataSetID() => datasetID;

  // ---------------------------------------------------------------------------
  // LoadContext — facet initialization
  // ---------------------------------------------------------------------------

  @override
  void loadCampaignFacets() {
    FacetLibrary.getFacet<DataSetInitializationFacet>(DataSetInitializationFacet)
        .initialize(this);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — forgetMeNot (prevent GC of references)
  // ---------------------------------------------------------------------------

  @override
  void forgetMeNot(CDOMReference<dynamic> cdr) {
    _dontForget.add(cdr);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — reference manufacturer lookup
  // ---------------------------------------------------------------------------

  @override
  ReferenceManufacturer<dynamic>? getManufacturer(String firstToken) {
    return ReferenceContextUtilities.getManufacturer(
        getReferenceContext(), firstToken);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — copy / perform copy
  // ---------------------------------------------------------------------------

  @override
  T performCopy<T extends CDOMObject>(T object, String copyName) {
    final copy = _ref.performCopy(object, copyName) as T;
    _list.cloneInMasterLists(object, copy);
    return copy;
  }

  // ---------------------------------------------------------------------------
  // LoadContext — token loading
  // ---------------------------------------------------------------------------

  @override
  void loadLocalToken(Object token) {
    _support.loadLocalToken(token);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — group support
  // ---------------------------------------------------------------------------

  @override
  GroupDefinition<T>? getGroup<T>(Type cl, String s) {
    return _support.getGroup<T>(cl, s);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — scope management
  // ---------------------------------------------------------------------------

  @override
  dynamic getActiveScope() {
    // PCGenScope — dynamic until fully translated
    _legalScope ??= _var.getScope(GlobalPCScope.globalScopeName);
    return _legalScope;
  }

  @override
  LoadContext dropIntoContext(String scope) {
    final subScope = _var.getScope(scope);
    if (subScope == null) {
      throw ArgumentError(
          'LegalVariableScope $scope does not exist');
    }
    return _dropIntoContextScope(subScope);
  }

  LoadContext _dropIntoContextScope(dynamic lvs) {
    // PCGenScope.getParentScope() → Optional<PCGenScope>
    // stub: represented as nullable dynamic
    final dynamic parent = _getParentScope(lvs); // stub
    if (parent == null) {
      // is Global — return self
      return this;
    }
    final LoadContext parentLC = _dropIntoContextScope(parent);
    return _DerivedLoadContext(parentLC, lvs, _support, _var);
  }

  // stub: PCGenScope.getParentScope() returning null means no parent (global)
  dynamic _getParentScope(dynamic scope) =>
      (scope as dynamic).getParentScope?.call(); // stub

  // ---------------------------------------------------------------------------
  // LoadContext — deferred method controllers
  // ---------------------------------------------------------------------------

  @override
  void addDeferredMethodController(DeferredMethodController commitTask) {
    _commitTasks.add(commitTask);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — formula validation
  // ---------------------------------------------------------------------------

  @override
  NEPFormula<T> getValidFormula<T>(
      FormatManager<T> formatManager, String instructions) {
    return _var.getValidFormula(getActiveScope(), formatManager, instructions);
  }

  // ---------------------------------------------------------------------------
  // LoadContext — grouping
  // ---------------------------------------------------------------------------

  @override
  dynamic getGrouping(dynamic scope, String groupingName) {
    // GroupingCollection<?> — dynamic
    try {
      final info = GroupingInfoFactory().process(scope, groupingName);
      return ChoiceSetLoadUtilities.getDynamicGroup(this, info);
    } on GroupingStateException catch (e) {
      print('Error in parsing Group: ${e.message}');
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// _DerivedLoadContext — inner scope context (package-private in Java)
// ---------------------------------------------------------------------------

/// A DerivedLoadContext holds an inner scope, but delegates all functions
/// to the parent LoadContext. Corresponds to the Java private inner class.
class _DerivedLoadContext implements LoadContext {
  final LoadContext _parent;
  final dynamic _derivedScope; // PCGenScope — dynamic until fully translated
  final TokenSupport _support;
  final VariableContext _var;

  _DerivedLoadContext(
      this._parent, this._derivedScope, this._support, this._var);

  // ---- URI management ----

  @override
  void setExtractURI(String? extractURI) =>
      _parent.setExtractURI(extractURI);

  @override
  void setSourceURI(String? sourceURI) =>
      _parent.setSourceURI(sourceURI);

  @override
  String? getSourceURI() => _parent.getSourceURI();

  // ---- data set ----

  @override
  DataSetID getDataSetID() => _parent.getDataSetID();

  // ---- sub-contexts ----

  @override
  AbstractReferenceContext getReferenceContext() =>
      _parent.getReferenceContext();

  @override
  AbstractObjectContext getObjectContext() => _parent.getObjectContext();

  @override
  AbstractListContext getListContext() => _parent.getListContext();

  @override
  bool consolidate() => _parent.consolidate();

  @override
  VariableContext getVariableContext() => _parent.getVariableContext();

  // ---- commit / rollback ----

  @override
  void commit() => _parent.commit();

  @override
  void rollback() => _parent.rollback();

  // ---- deferred tokens ----

  @override
  void resolveDeferredTokens() => _parent.resolveDeferredTokens();

  @override
  void resolvePostDeferredTokens() => _parent.resolvePostDeferredTokens();

  @override
  void resolvePostValidationTokens() =>
      _parent.resolvePostValidationTokens();

  // ---- choice sets ----

  @override
  PrimitiveCollection<T>? getChoiceSet<T extends CDOMObject>(
      SelectionCreator<T> sc, String value) =>
      _parent.getChoiceSet(sc, value);

  @override
  PrimitiveCollection<T>? getPrimitiveChoiceFilter<T extends CDOMObject>(
      SelectionCreator<T> sc, String key) =>
      _parent.getPrimitiveChoiceFilter(sc, key);

  // ---- prerequisite string ----

  @override
  String? getPrerequisiteString(List<Prerequisite> prereqs) =>
      _parent.getPrerequisiteString(prereqs);

  // ---- reference manufacturer ----

  @override
  ReferenceManufacturer<dynamic>? getManufacturer(String firstToken) =>
      _parent.getManufacturer(firstToken);

  // ---- forgetMeNot ----

  @override
  void forgetMeNot(CDOMReference<dynamic> cdr) => _parent.forgetMeNot(cdr);

  // ---- CDOMObject cloning ----

  @override
  T cloneConstructedCDOMObject<T extends CDOMObject>(T cdo, String newName) =>
      _parent.cloneConstructedCDOMObject(cdo, newName);

  // ---- campaign source entry ----

  @override
  CampaignSourceEntry? getCampaignSourceEntry(Campaign source, String value) =>
      _parent.getCampaignSourceEntry(source, value);

  // ---- stateful information ----

  @override
  void clearStatefulInformation() =>
      _parent.clearStatefulInformation();

  @override
  bool addStatefulToken(String s) => _parent.addStatefulToken(s);

  @override
  void addStatefulInformation(CDOMObject target) =>
      _parent.addStatefulInformation(target);

  // ---- campaign list ----

  @override
  void setLoaded(List<Campaign> campaigns) => _parent.setLoaded(campaigns);

  @override
  List<Campaign> getLoadedCampaigns() => _parent.getLoadedCampaigns();

  // ---- facet initialization ----

  @override
  void loadCampaignFacets() => _parent.loadCampaignFacets();

  // ---- copy ----

  @override
  T performCopy<T extends CDOMObject>(T object, String copyName) =>
      _parent.performCopy(object, copyName);

  // ---- token processing — these use *this* as context (not parent) ----

  @override
  ParseResult processSubToken<T>(
      T cdo, String tokenName, String key, String value) {
    return _support.processSubToken(this, cdo, tokenName, key, value)
        as ParseResult? ??
        ParseResult.fail;
  }

  @override
  bool processToken<T extends Loadable>(
      T derivative, String typeStr, String argument) {
    return _support.processToken(this, derivative, typeStr, argument);
  }

  @override
  void unconditionallyProcess<T extends Loadable>(
      T cdo, String key, String value) =>
      _parent.unconditionallyProcess(cdo, key, value);

  // ---- unparse — also uses *this* as context ----

  @override
  List<String> unparseSubtoken<T>(T cdo, String tokenName) {
    return _support.unparseSubtoken(this, cdo, tokenName);
  }

  @override
  List<String> unparse<T extends Loadable>(T cdo) {
    return _support.unparse(this, cdo);
  }

  // ---- write message ----

  @override
  void addWriteMessage(String string) => _parent.addWriteMessage(string);

  @override
  int getWriteMessageCount() => _parent.getWriteMessageCount();

  // ---- scope ----

  /// Returns the derived scope for this context (NOT the parent's scope).
  @override
  dynamic getActiveScope() => _derivedScope;

  @override
  LoadContext dropIntoContext(String scope) {
    final dynamic toScope = _var.getScope(scope);
    if (toScope == null) {
      throw ArgumentError('LegalVariableScope $scope does not exist');
    }
    if (toScope == _derivedScope) {
      return this;
    }
    // If toScope has no parent it is global — return outermost parent
    final dynamic toParent =
        (toScope as dynamic).getParentScope?.call(); // stub
    if (toParent == null) {
      return _parent;
    }
    // If toScope's parent IS our scope → direct child drop
    if (toParent == _derivedScope) {
      return _DerivedLoadContext(this, toScope, _support, _var);
    }
    // Otherwise fall back to the outer LoadContextInst to resolve from top
    // stub: LoadContextInst.this.dropIntoContextScope(toScope) —
    //       walk up to the root and re-enter
    return _dropFromRoot(_parent, toScope, _support, _var);
  }

  // stub: walk up to root LoadContextInst and call _dropIntoContextScope
  static LoadContext _dropFromRoot(LoadContext parent, dynamic scope,
      TokenSupport support, VariableContext var_) {
    // Delegate upwards until we reach a LoadContextInst
    if (parent is LoadContextInst) {
      return parent._dropIntoContextScope(scope);
    }
    if (parent is _DerivedLoadContext) {
      return _dropFromRoot(parent._parent, scope, support, var_);
    }
    throw StateError('Cannot resolve scope from context hierarchy');
  }

  // ---- token loading ----

  @override
  void loadLocalToken(Object token) => _parent.loadLocalToken(token);

  // ---- group support ----

  @override
  GroupDefinition<T>? getGroup<T>(Type cl, String s) =>
      _parent.getGroup(cl, s);

  // ---- deferred method controllers ----

  @override
  void addDeferredMethodController(DeferredMethodController controller) =>
      _parent.addDeferredMethodController(controller);

  // ---- grouping ----

  @override
  dynamic getGrouping(dynamic scope, String groupingName) =>
      _parent.getGrouping(scope, groupingName);

  // ---- formula ----

  @override
  NEPFormula<T> getValidFormula<T>(
      FormatManager<T> formatManager, String instructions) =>
      _parent.getValidFormula(formatManager, instructions);
}
