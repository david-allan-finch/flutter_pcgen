// Copyright (c) Tom Parker, 2009.
//
// Translation of pcgen.cdom.formula.FixedSizeFormula

import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';

/// A Formula that always resolves to the SIZEORDER of a fixed SizeAdjustment.
class FixedSizeFormula {
  final CDOMSingleRef<dynamic> size;

  FixedSizeFormula(this.size);

  bool get isStatic => true;
  bool get isValid => true;

  int resolveStatic() {
    return size.get().get(IntegerKey.getConstant('SIZEORDER')) as int? ?? 0;
  }

  int resolve(dynamic pc, String source) => resolveStatic();

  @override
  String toString() => size.getLSTformat(false);

  @override
  bool operator ==(Object other) =>
      other is FixedSizeFormula && size == other.size;

  @override
  int get hashCode => size.hashCode;
}
