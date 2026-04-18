// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.DDList

import 'dart:math';

import 'data_element.dart';
import 'data_value.dart';
import 'weighted_data_value.dart';

/// A DDList is a weighted list of WeightedDataValues. When getData() is called,
/// it rolls a virtual die (summing all weights) and selects an entry by weighted
/// random pick.
///
/// Extends List<WeightedDataValue>.
class DDList extends DataElement {
  final String _id;
  final String _title;
  final int _weight;
  final List<WeightedDataValue> _entries = [];
  DataValue? _lastData;

  static final Random _random = Random();

  DDList(this._id, this._title, this._weight);

  void add(WeightedDataValue entry) => _entries.add(entry);

  @override
  String getId() => _id;

  @override
  String getTitle() => _title;

  @override
  int getWeight() => _weight;

  @override
  DataValue? getLastData() => _lastData;

  /// Performs a weighted random selection among entries and returns the chosen
  /// DataValue.
  @override
  DataValue getData() {
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
    _lastData = DataValue(chosen.getValue(), chosen.getSubValue());
    return _lastData!;
  }
}
