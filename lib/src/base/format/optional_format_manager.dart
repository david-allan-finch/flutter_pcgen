import '../util/format_manager.dart';
import '../util/basic_indirect.dart';
import '../util/indirect.dart';
import '../util/object_container.dart';

class _OptionalContainer<T> implements ObjectContainer<T?> {
  final T? _value;
  final FormatManager<T> _componentFormat;

  _OptionalContainer(this._value, this._componentFormat);

  @override
  List<T?> getContainedObjects() => [_value];

  @override
  String getLSTformat() =>
      _value == null ? '' : _componentFormat.unconvert(_value!);
}

class OptionalFormatManager<T> implements FormatManager<T?> {
  final FormatManager<T> _componentFormat;

  OptionalFormatManager(this._componentFormat);

  @override
  T? convert(String inputStr) {
    if (inputStr.isEmpty) return null;
    return _componentFormat.convert(inputStr);
  }

  @override
  Indirect<T?> convertIndirect(String inputStr) =>
      BasicIndirect(convert(inputStr), inputStr);

  @override
  ObjectContainer<T?> convertObjectContainer(String inputStr) =>
      _OptionalContainer(convert(inputStr), _componentFormat);

  @override
  String unconvert(T? obj) => obj == null ? '' : _componentFormat.unconvert(obj);

  @override
  Type getManagedClass() => _componentFormat.getManagedClass();

  @override
  String getIdentifierType() => 'OPTIONAL[${_componentFormat.getIdentifierType()}]';

  @override
  FormatManager<dynamic>? getComponentManager() => _componentFormat;
}
