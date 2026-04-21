import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/util/basic_indirect.dart';
import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'package:flutter_pcgen/src/base/util/object_container.dart';
import 'package:flutter_pcgen/src/base/util/value_store.dart';

class _NumberContainer implements ObjectContainer<num> {
  final num _value;
  const _NumberContainer(this._value);

  @override
  List<num> getContainedObjects() => [_value];

  @override
  String getLSTformat() => _value.toString();
}

class NumberManager implements FormatManager<num> {
  const NumberManager();

  @override
  num convert(String inputStr) {
    final n = num.tryParse(inputStr);
    if (n == null) throw ArgumentError('Cannot convert "$inputStr" to Number');
    return n;
  }

  @override
  Indirect<num> convertIndirect(String inputStr) =>
      BasicIndirect(convert(inputStr), inputStr);

  @override
  ObjectContainer<num> convertObjectContainer(String inputStr) =>
      _NumberContainer(convert(inputStr));

  @override
  String unconvert(num obj) => obj.toString();

  @override
  Type getManagedClass() => num;

  @override
  String getIdentifierType() => 'NUMBER';

  @override
  FormatManager<dynamic>? getComponentManager() => null;
}
