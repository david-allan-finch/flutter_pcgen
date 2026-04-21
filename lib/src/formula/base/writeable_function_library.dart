import 'package:flutter_pcgen/src/formula/base/formula_function.dart';
import 'package:flutter_pcgen/src/formula/base/function_library.dart';

abstract interface class WriteableFunctionLibrary implements FunctionLibrary {
  void addFunction(FormulaFunction function);
}
