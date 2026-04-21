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
// Translation of pcgen.cdom.base.JEPFormula
// JEPFormula is a variable-value Formula evaluated through the JEP formula
// evaluation system.  It delegates resolution to the PlayerCharacter.
class JEPFormula {
  final String _formula;

  // Package-private constructor; use FormulaFactory to create instances.
  JEPFormula(this._formula);

  @override
  String toString() => _formula;

  @override
  int get hashCode => _formula.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is JEPFormula && obj._formula == _formula;

  /// Resolves the formula in the context of the given PlayerCharacter.
  num resolve(dynamic character, String source) {
    return character.getVariableValue(_formula, source) as num;
  }

  /// Returns false: a JEPFormula depends on the character state.
  bool isStatic() => false;

  /// Resolves the formula given an Equipment context.
  num resolveEquipment(dynamic equipment, bool primary, dynamic pc, String source) {
    return equipment.getVariableValue(_formula, source, primary, pc) as num;
  }

  bool isValid() => true;

  num resolveStatic() {
    throw UnsupportedError('Formula is not static');
  }
}
