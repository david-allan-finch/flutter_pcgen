import '../../base/formula/formula.dart';
import '../../base/formula/number_formula.dart';
import '../../base/formula/string_formula.dart';

// Factory for creating Formula objects.
class FormulaFactory {
  FormulaFactory._();

  static const Formula zero = NumberFormula(0);
  static const Formula one = NumberFormula(1);

  static Formula getFormulaFor(String formulaString) {
    if (formulaString.isEmpty) {
      throw ArgumentError('Formula cannot be empty');
    }
    final n = int.tryParse(formulaString);
    if (n != null) return NumberFormula(n);
    final d = double.tryParse(formulaString);
    if (d != null) return NumberFormula(d);
    return StringFormula(formulaString);
  }

  static Formula getFormulaForNum(num value) {
    return NumberFormula(value);
  }
}
