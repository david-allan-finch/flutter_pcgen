import 'package:flutter_pcgen/src/base/lang/case_insensitive_string.dart';
import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'scope_instance.dart';

class VariableID<T> {
  final FormatManager<T> formatManager;
  final ScopeInstance scope;
  final CaseInsensitiveString _varName;

  VariableID(ScopeInstance scopeInst, FormatManager<T> formatManager, String varName)
      : scope = scopeInst,
        formatManager = formatManager,
        _varName = CaseInsensitiveString(varName) {
    checkLegalVarName(varName);
  }

  String getName() => _varName.toString();

  ScopeInstance getScope() => scope;

  FormatManager<T> getFormatManager() => formatManager;

  @override
  int get hashCode {
    const prime = 31;
    int result = prime + _varName.hashCode;
    result = (prime * result) + scope.hashCode;
    return result;
  }

  @override
  bool operator ==(Object obj) {
    if (obj is VariableID) {
      return _varName == obj._varName &&
          formatManager == obj.formatManager &&
          scope == obj.scope;
    }
    return false;
  }

  @override
  String toString() =>
      '${scope.getImplementedScope().getName()} Variable: $_varName (${formatManager.getIdentifierType()})';

  static void checkLegalVarName(String varName) {
    if (varName.isEmpty) {
      throw ArgumentError('Variable Name cannot be empty');
    }
    if (varName != varName.trim()) {
      throw ArgumentError('Variable Name cannot start/end with whitespace');
    }
  }
}
