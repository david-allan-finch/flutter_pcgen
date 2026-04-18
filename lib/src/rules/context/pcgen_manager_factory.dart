import 'load_context.dart';

// stub: formula base types not yet translated to Dart
// DependencyManager, EvaluationManager, FormulaManager, FormulaSemantics,
// LegalScope, ManagerFactory, ScopeInstance are represented as dynamic.

/// PCGenManagerFactory is a ManagerFactory responsible for ensuring the
/// Managers are constructed with sufficient support to work with the formula
/// functions provided in PCGen.
class PCGenManagerFactory /* implements ManagerFactory */ {
  // Dart has no WeakReference in the standard library; use a plain reference.
  // stub: use WeakReference from dart:core when available (Dart >= 2.17)
  final LoadContext _context;

  PCGenManagerFactory(LoadContext context) : _context = context;

  /// Generates a FormulaSemantics with the LoadContext injected under
  /// ManagerKey.CONTEXT.
  dynamic generateFormulaSemantics(dynamic manager, dynamic legalScope) {
    // stub: ManagerFactory.super.generateFormulaSemantics not available
    dynamic semantics = _defaultFormulaSemantics(manager, legalScope); // stub
    return semantics; // stub: .getWith(ManagerKey.CONTEXT, _context)
  }

  /// Generates an EvaluationManager with the LoadContext injected under
  /// ManagerKey.CONTEXT.
  dynamic generateEvaluationManager(dynamic formulaManager) {
    // stub: ManagerFactory.super.generateEvaluationManager not available
    dynamic evalManager = _defaultEvaluationManager(formulaManager); // stub
    return evalManager; // stub: .getWith(ManagerKey.CONTEXT, _context)
  }

  /// Generates a DependencyManager with the LoadContext and a new
  /// ReferenceDependency injected.
  dynamic generateDependencyManager(dynamic formulaManager, dynamic scopeInst) {
    // stub: ManagerFactory.super.generateDependencyManager not available
    dynamic depManager =
        _defaultDependencyManager(formulaManager, scopeInst); // stub
    return depManager;
    // stub: .getWith(ManagerKey.CONTEXT, _context)
    //       .getWith(ManagerKey.REFERENCES, ReferenceDependency())
  }

  // stub helpers (would normally be default interface methods in Java)
  dynamic _defaultFormulaSemantics(dynamic manager, dynamic legalScope) =>
      null; // stub
  dynamic _defaultEvaluationManager(dynamic formulaManager) => null; // stub
  dynamic _defaultDependencyManager(dynamic formulaManager, dynamic scopeInst) =>
      null; // stub
}
