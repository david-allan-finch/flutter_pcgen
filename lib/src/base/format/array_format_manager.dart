import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/util/basic_indirect.dart';
import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'package:flutter_pcgen/src/base/util/object_container.dart';

class _ArrayContainer<T> implements ObjectContainer<List<T>> {
  final List<T> _value;
  final FormatManager<T> _componentFormat;

  _ArrayContainer(this._value, this._componentFormat);

  @override
  List<List<T>> getContainedObjects() => [_value];

  @override
  String getLSTformat([bool useAny = false]) =>
      _value.map((v) => _componentFormat.unconvert(v)).join(',');
}

class ArrayFormatManager<T> implements FormatManager<List<T>> {
  final FormatManager<T> _componentFormat;
  final String _separator;

  ArrayFormatManager(this._componentFormat, [this._separator = ',']);

  @override
  List<T> convert(String inputStr) {
    if (inputStr.isEmpty) return [];
    return inputStr.split(_separator).map((s) => _componentFormat.convert(s.trim())).toList();
  }

  @override
  Indirect<List<T>> convertIndirect(String inputStr) =>
      BasicIndirect(convert(inputStr), inputStr);

  @override
  ObjectContainer<List<T>> convertObjectContainer(String inputStr) =>
      _ArrayContainer(convert(inputStr), _componentFormat);

  @override
  String unconvert(List<T> obj) =>
      obj.map((v) => _componentFormat.unconvert(v)).join(_separator);

  @override
  Type getManagedClass() => List;

  @override
  String getIdentifierType() => 'ARRAY[${_componentFormat.getIdentifierType()}]';

  @override
  FormatManager<dynamic>? getComponentManager() => _componentFormat;
}
