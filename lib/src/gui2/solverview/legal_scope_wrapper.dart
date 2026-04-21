// Translation of pcgen.gui2.solverview.LegalScopeWrapper

/// Wraps a legal scope for display in the solver view tree.
class LegalScopeWrapper {
  final dynamic scope;

  LegalScopeWrapper(this.scope);

  String getDisplayName() {
    try { return scope?.getName()?.toString() ?? scope.toString(); }
    catch (_) { return scope.toString(); }
  }

  @override
  String toString() => getDisplayName();
}
