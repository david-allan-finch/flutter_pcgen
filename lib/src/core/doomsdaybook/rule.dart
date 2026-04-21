// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.Rule

import 'package:flutter_pcgen/src/core/doomsdaybook/data_element.dart';
import 'package:flutter_pcgen/src/core/doomsdaybook/data_value.dart';
import 'package:flutter_pcgen/src/core/doomsdaybook/variable_hash_map.dart';

/// A Rule is an ordered list of DataElement keys that, when evaluated, concatenates
/// the results of each referenced element to form a single DataValue.
///
/// Extends List<String> (the list of element-id keys).
class Rule extends DataElement {
  final String _id;
  final String _title;
  final int _weight;
  final List<String> _keys = [];
  DataValue? _lastData;

  Rule(this._id, this._title, this._weight);

  void add(String key) => _keys.add(key);

  @override
  String getId() => _id;

  @override
  String getTitle() => _title;

  @override
  int getWeight() => _weight;

  @override
  DataValue? getLastData() => _lastData;

  /// Evaluates each referenced key in [allVars], concatenating their DataValue output.
  @override
  DataValue getData([VariableHashMap? allVars]) {
    if (allVars == null) {
      _lastData = DataValue('');
      return _lastData!;
    }
    final buffer = StringBuffer();
    for (final key in _keys) {
      final elem = allVars.getDataElement(key);
      if (elem != null) {
        final dv = elem.getData() as DataValue;
        buffer.write(dv.getValue());
      } else if (allVars.containsKey(key)) {
        buffer.write(allVars[key]);
      } else {
        final parsed = allVars.parse(key);
        buffer.write(parsed.getValue());
      }
    }
    _lastData = DataValue(buffer.toString());
    return _lastData!;
  }
}
