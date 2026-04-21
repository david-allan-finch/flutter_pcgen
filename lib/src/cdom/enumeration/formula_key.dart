//
// Copyright (c) 2006 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.FormulaKey
import 'package:flutter_pcgen/src/base/util/case_insensitive_map.dart';

// Typesafe constant for Formula characteristics of a CDOMObject.
class FormulaKey {
  static final CaseInsensitiveMap<FormulaKey> _typeMap = CaseInsensitiveMap();
  static int _ordinalCount = 0;

  static final FormulaKey levelAdjustment = getConstant('LEVEL_ADJUSTMENT');
  static final FormulaKey startSkillPoints = getConstant('START_SKILL_POINTS');
  static final FormulaKey cost = getConstant('COST');
  static final FormulaKey basecost = getConstant('BASECOST');
  static final FormulaKey pageUsage = getConstant('PAGE_USAGE');
  static final FormulaKey cr = getConstant('CR');
  static final FormulaKey crmod = getConstant('CRMOD');
  static final FormulaKey select = getConstant('SELECT', defaultFormula: '1');
  static final FormulaKey numchoices = getConstant('NUMCHOICES');
  static final FormulaKey size = getConstant('SIZE', defaultFormula: '0');
  static final FormulaKey statMod = getConstant('STAT_MOD');
  static final FormulaKey skillPointsPerLevel = getConstant('SKILL_POINTS_PER_LEVEL');

  final String _fieldName;
  final String _defaultFormula;
  final int ordinal;

  FormulaKey._(this._fieldName, this._defaultFormula) : ordinal = _ordinalCount++;

  String getDefault() => _defaultFormula;

  @override
  String toString() => _fieldName;

  static FormulaKey getConstant(String name, {String defaultFormula = '0'}) {
    final existing = _typeMap[name];
    if (existing != null) return existing;
    final key = FormulaKey._(name, defaultFormula);
    _typeMap[name] = key;
    return key;
  }

  static FormulaKey valueOf(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined FormulaKey');
    return key;
  }

  static Iterable<FormulaKey> getAllConstants() => List.unmodifiable(_typeMap.values());

  static void clearConstants() => _typeMap.clear();
}
