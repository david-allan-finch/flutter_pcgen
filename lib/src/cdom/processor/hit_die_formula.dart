//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.processor.HitDieFormula
import 'package:flutter_pcgen/src/cdom/content/hit_die.dart';
import 'package:flutter_pcgen/src/cdom/content/processor.dart';

// A Processor that applies a ReferenceFormula to modify a HitDie's die value.
class HitDieFormula implements Processor<HitDie> {
  final dynamic _formula; // ReferenceFormula<Integer>

  HitDieFormula(dynamic refFormula) : _formula = refFormula;

  @override
  HitDie applyProcessor(HitDie origHD, Object? context) =>
      HitDie(_formula.resolve(origHD.getDie()) as int);

  @override
  String getLSTformat() => '%$_formula';

  @override
  Type getModifiedClass() => HitDie;

  @override
  int get hashCode => _formula.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is HitDieFormula && obj._formula == _formula;
}
