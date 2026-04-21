import 'package:flutter_pcgen/src/base/util/indirect.dart';

class BasicIndirect<T> implements Indirect<T> {
  final T _value;
  final String _unconverted;

  const BasicIndirect(this._value, this._unconverted);

  @override
  T get() => _value;

  @override
  String getUnconverted() => _unconverted;

  @override
  String toString() => _unconverted;
}
