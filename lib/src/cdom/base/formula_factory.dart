//
// Copyright (c) 2007 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.base.FormulaFactory
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
