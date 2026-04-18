// Interface for objects that have a PCGen scope (variable scoping).
abstract interface class PCGenScoped {
  String? getScopeName();
  PCGenScoped? getEnclosingScope();

  /// Returns variable names whose values grant objects to the PC.
  List<String> getGrantedVariableArray() => const [];
}
