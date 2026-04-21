import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/exception/legal_variable_exception.dart';
import 'implemented_scope.dart';
import 'scope_instance.dart';
import 'variable_id.dart';

abstract interface class VariableLibrary {
  void assertLegalVariableID(String varName, ImplementedScope scope,
      FormatManager<dynamic> formatManager);

  bool isLegalVariableID(ImplementedScope scope, String varName);

  FormatManager<dynamic>? getVariableFormat(ImplementedScope scope, String varName);

  VariableID<dynamic> getVariableID(ScopeInstance scopeInst, String varName);

  List<FormatManager<dynamic>> getInvalidFormats();

  T getDefault<T>(FormatManager<T> formatManager);
}
