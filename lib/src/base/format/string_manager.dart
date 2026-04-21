import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/util/basic_indirect.dart';
import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'package:flutter_pcgen/src/base/util/object_container.dart';

class _StringContainer implements ObjectContainer<String> {
  final String _value;
  const _StringContainer(this._value);

  @override
  List<String> getContainedObjects() => [_value];

  @override
  String getLSTformat() => _value;
}

class StringManager implements FormatManager<String> {
  const StringManager();

  @override
  String convert(String inputStr) => inputStr;

  @override
  Indirect<String> convertIndirect(String inputStr) =>
      BasicIndirect(inputStr, inputStr);

  @override
  ObjectContainer<String> convertObjectContainer(String inputStr) =>
      _StringContainer(inputStr);

  @override
  String unconvert(String obj) => obj;

  @override
  Type getManagedClass() => String;

  @override
  String getIdentifierType() => 'STRING';

  @override
  FormatManager<dynamic>? getComponentManager() => null;
}
