//
// Copyright 2017 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.content.IndirectCalculation
import '../../base/util/indirect.dart';

// An IndirectCalculation wraps an Indirect object and a BasicCalculation,
// applying the calculation's operation using the indirect's resolved value.
//
// Equivalent to the formula system's AbstractNEPCalculation with an Indirect.
class IndirectCalculation<T> {
  final Indirect<T> _obj;
  final dynamic _basicCalculation; // BasicCalculation<T> — typed loosely

  IndirectCalculation(Indirect<T> object, dynamic calc)
      : _obj = object,
        _basicCalculation = calc;

  T process(dynamic evalManager) {
    final T? input = evalManager?.get(#INPUT) as T?;
    return _basicCalculation.process(input, _obj.get()) as T;
  }

  String getInstructions() => _obj.getUnconverted();

  dynamic getBasicCalculation() => _basicCalculation;

  @override
  int get hashCode => _obj.hashCode ^ _basicCalculation.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is IndirectCalculation<T>) {
      return o._basicCalculation == _basicCalculation && o._obj == _obj;
    }
    return false;
  }
}
