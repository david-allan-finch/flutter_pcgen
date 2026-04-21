import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/util/basic_indirect.dart';
import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'package:flutter_pcgen/src/base/util/object_container.dart';

class _BoolContainer implements ObjectContainer<bool> {
  final bool _value;
  const _BoolContainer(this._value);

  @override
  List<bool> getContainedObjects() => [_value];

  @override
  String getLSTformat([bool useAny = false]) => _value ? 'TRUE' : 'FALSE';
}

class BooleanManager implements FormatManager<bool> {
  const BooleanManager();

  @override
  bool convert(String inputStr) {
    final upper = inputStr.toUpperCase();
    if (upper == 'TRUE') return true;
    if (upper == 'FALSE') return false;
    throw ArgumentError('Cannot convert "$inputStr" to Boolean');
  }

  @override
  Indirect<bool> convertIndirect(String inputStr) =>
      BasicIndirect(convert(inputStr), inputStr);

  @override
  ObjectContainer<bool> convertObjectContainer(String inputStr) =>
      _BoolContainer(convert(inputStr));

  @override
  String unconvert(bool obj) => obj ? 'TRUE' : 'FALSE';

  @override
  Type getManagedClass() => bool;

  @override
  String getIdentifierType() => 'BOOLEAN';

  @override
  FormatManager<dynamic>? getComponentManager() => null;
}
