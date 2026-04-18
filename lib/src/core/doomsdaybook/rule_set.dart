// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.RuleSet

import 'dart:math';

import 'data_element.dart';
import 'data_value.dart';
import 'variable_hash_map.dart';
import 'weighted_data_value.dart';

/// A RuleSet is a weighted collection of DataElement keys. When evaluated, it
/// randomly selects one key using weighted random selection and returns the
/// result of evaluating that element.
///
/// Extends List<String> (list of element-id keys with associated weights).
class RuleSet extends DataElement {
  final String _id;
  final String _title;
  final int _weight;
  final List<WeightedDataValue> _entries = [];
  DataValue? _lastData;

  static final Random _random = Random();

  RuleSet(this._id, this._title, this._weight);

  void add(WeightedDataValue entry) => _entries.add(entry);

  @override
  String getId() => _id;

  @override
  String getTitle() => _title;

  @override
  int getWeight() => _weight;

  @override
  DataValue? getLastData() => _lastData;

  /// Randomly selects one entry using weighted random selection, then evaluates
  /// the chosen DataElement via [allVars].
  @override
  DataValue getData([VariableHashMap? allVars]) {
    if (_entries.isEmpty) {
      _lastData = DataValue('');
      return _lastData!;
    }
    final totalWeight =
        _entries.fold(0, (sum, e) => sum + e.getWeight());
    var roll = _random.nextInt(totalWeight);
    WeightedDataValue chosen = _entries.last;
    for (final entry in _entries) {
      roll -= entry.getWeight();
      if (roll < 0) {
        chosen = entry;
        break;
      }
    }
    if (allVars != null) {
      final key = chosen.getValue();
      final elem = allVars.getDataElement(key);
      if (elem != null) {
        _lastData = elem.getData() as DataValue?;
        return _lastData ?? DataValue('');
      }
    }
    _lastData = DataValue(chosen.getValue());
    return _lastData!;
  }
}
