import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/util/basic_indirect.dart';
import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'package:flutter_pcgen/src/base/util/object_container.dart';
import 'package:flutter_pcgen/src/base/format/compound/compound.dart';
import 'package:flutter_pcgen/src/base/format/compound/direct_compound.dart';
import 'package:flutter_pcgen/src/base/format/compound/secondary_definition.dart';

class _CompoundContainer implements ObjectContainer<Compound> {
  final Compound _value;
  const _CompoundContainer(this._value);

  @override
  List<Compound> getContainedObjects() => [_value];

  @override
  String getLSTformat([bool useAny = false]) => _value.toString();
}

class CompoundFormatManager extends FormatManager<Compound> {
  final FormatManager<dynamic> _primaryFormat;
  final List<SecondaryDefinition> _secondaryDefs;
  final String _separator;

  CompoundFormatManager(this._primaryFormat, this._secondaryDefs, [this._separator = '|']);

  @override
  Compound convert(String inputStr) {
    final parts = inputStr.split(_separator);
    final primary = _primaryFormat.convert(parts[0]);
    final secondaries = <String, Object>{};
    for (int i = 1; i < parts.length; i++) {
      final kv = parts[i].split('=');
      if (kv.length == 2) {
        final def = _secondaryDefs.where((d) => d.name == kv[0]).firstOrNull;
        if (def != null) {
          secondaries[kv[0]] = def.formatManager.convert(kv[1]);
        }
      }
    }
    return DirectCompound(primary, _primaryFormat, secondaries);
  }

  @override
  Indirect<Compound> convertIndirect(String inputStr) =>
      BasicIndirect(convert(inputStr), inputStr);

  @override
  ObjectContainer<Compound> convertObjectContainer(String inputStr) =>
      _CompoundContainer(convert(inputStr));

  @override
  String unconvert(Compound obj) => obj.toString();

  @override
  Type getManagedClass() => Compound;

  @override
  String getIdentifierType() {
    final secondaryNames = _secondaryDefs.map((d) => d.name).join(',');
    return 'COMPOUND[${_primaryFormat.getIdentifierType()}][$secondaryNames]';
  }

  @override
  FormatManager<dynamic>? getComponentManager() => _primaryFormat;
}
