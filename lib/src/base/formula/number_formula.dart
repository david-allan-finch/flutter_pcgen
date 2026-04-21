import 'package:flutter_pcgen/src/base/formula/formula.dart';

// A Formula that represents a numeric constant.
class NumberFormula implements Formula {
  final num _value;

  const NumberFormula(this._value);

  @override
  num resolve(dynamic pc, String source) => _value;

  @override
  num resolveStatic() => _value;

  @override
  num resolveEquipment(dynamic equipment, bool primary, dynamic pc, String source) => _value;

  @override
  bool isStatic() => true;

  @override
  bool isValid() => true;

  @override
  String toString() => _value.toString();
}
