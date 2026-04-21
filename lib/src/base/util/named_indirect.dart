import 'package:flutter_pcgen/src/base/util/indirect.dart';

class NamedIndirect<T> implements Indirect<T> {
  final String _name;
  final T _value;

  const NamedIndirect(this._name, this._value);

  @override
  T get() => _value;

  @override
  String getUnconverted() => _name;

  @override
  String toString() => _name;
}
