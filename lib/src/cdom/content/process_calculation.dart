//
// Copyright 2014 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.ProcessCalculation
import '../../base/util/format_manager.dart';

// A ProcessCalculation wraps a direct object and a BasicCalculation, applying
// the calculation's operation using the stored object as the operand.
class ProcessCalculation<T> {
  final T _obj;
  final dynamic _basicCalculation; // BasicCalculation<T> — typed loosely
  final FormatManager<T> _formatManager;

  ProcessCalculation(T object, dynamic calc, FormatManager<T> fmtManager)
      : _obj = object,
        _basicCalculation = calc,
        _formatManager = fmtManager;

  T process(dynamic evalManager) {
    final T? input = evalManager?.get(#INPUT) as T?;
    return _basicCalculation.process(input, _obj) as T;
  }

  String getInstructions() => _formatManager.unconvert(_obj);

  dynamic getBasicCalculation() => _basicCalculation;

  @override
  int get hashCode => _obj.hashCode ^ _basicCalculation.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is ProcessCalculation<T>) {
      return o._basicCalculation == _basicCalculation && o._obj == _obj;
    }
    return false;
  }
}
