import '../../base/util/format_manager.dart';
import '../base/implemented_scope.dart';
import '../base/scope_instance.dart';
import '../base/variable_id.dart';
import '../base/variable_library.dart';
import '../exception/legal_variable_exception.dart';

class VariableManager implements VariableLibrary {
  // Maps variable name (lowercase) to its defining scope and format
  final Map<String, Map<ImplementedScope, FormatManager<dynamic>>> _variables = {};

  @override
  void assertLegalVariableID(String varName, ImplementedScope scope,
      FormatManager<dynamic> formatManager) {
    VariableID.checkLegalVarName(varName);
    final lowerName = varName.toLowerCase();
    final scopeMap = _variables.putIfAbsent(lowerName, () => {});

    if (scopeMap.containsKey(scope)) {
      final existing = scopeMap[scope]!;
      if (existing.getIdentifierType() != formatManager.getIdentifierType()) {
        throw LegalVariableException(
            'Variable $varName already defined in scope ${scope.getName()} '
            'with different format: ${existing.getIdentifierType()}');
      }
    } else {
      // Check for conflicting scopes
      for (final existingScope in scopeMap.keys) {
        if (_scopesConflict(scope, existingScope)) {
          throw LegalVariableException(
              'Variable $varName conflicts between scopes '
              '${scope.getName()} and ${existingScope.getName()}');
        }
      }
      scopeMap[scope] = formatManager;
    }
  }

  bool _scopesConflict(ImplementedScope a, ImplementedScope b) {
    if (a == b) return true;
    if (a.drawsFrom().contains(b)) return true;
    if (b.drawsFrom().contains(a)) return true;
    return false;
  }

  @override
  bool isLegalVariableID(ImplementedScope scope, String varName) {
    final scopeMap = _variables[varName.toLowerCase()];
    if (scopeMap == null) return false;
    if (scopeMap.containsKey(scope)) return true;
    for (final drawFrom in scope.drawsFrom()) {
      if (scopeMap.containsKey(drawFrom)) return true;
    }
    return false;
  }

  @override
  FormatManager<dynamic>? getVariableFormat(ImplementedScope scope, String varName) {
    final scopeMap = _variables[varName.toLowerCase()];
    if (scopeMap == null) return null;
    if (scopeMap.containsKey(scope)) return scopeMap[scope];
    for (final drawFrom in scope.drawsFrom()) {
      if (scopeMap.containsKey(drawFrom)) return scopeMap[drawFrom];
    }
    return null;
  }

  @override
  VariableID<dynamic> getVariableID(ScopeInstance scopeInst, String varName) {
    final scope = scopeInst.getImplementedScope();
    final format = getVariableFormat(scope, varName);
    if (format == null) {
      throw ArgumentError(
          'Variable $varName is not legal in scope ${scope.getName()}');
    }
    return VariableID(scopeInst, format, varName);
  }

  @override
  List<FormatManager<dynamic>> getInvalidFormats() => [];

  @override
  T getDefault<T>(FormatManager<T> formatManager) {
    throw UnimplementedError('getDefault not implemented in VariableManager');
  }
}
