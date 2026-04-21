import 'package:flutter_pcgen/src/formula/base/formula_function.dart';

abstract interface class FunctionLibrary {
  FormulaFunction? getFunction(String functionName);
}
