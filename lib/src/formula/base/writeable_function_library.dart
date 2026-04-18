import 'formula_function.dart';
import 'function_library.dart';

abstract interface class WriteableFunctionLibrary implements FunctionLibrary {
  void addFunction(FormulaFunction function);
}
