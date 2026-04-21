import 'package:flutter_pcgen/src/formula/base/formula_function.dart';
import 'package:flutter_pcgen/src/formula/base/function_library.dart';
import 'package:flutter_pcgen/src/formula/base/writeable_function_library.dart';

class SimpleFunctionLibrary implements WriteableFunctionLibrary {
  final Map<String, FormulaFunction> _functions = {};

  @override
  FormulaFunction? getFunction(String functionName) =>
      _functions[functionName.toUpperCase()];

  @override
  void addFunction(FormulaFunction function) {
    final name = function.getFunctionName().toUpperCase();
    if (_functions.containsKey(name)) {
      throw ArgumentError('Function already exists: ${function.getFunctionName()}');
    }
    _functions[name] = function;
  }
}
