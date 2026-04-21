// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.core.kit.KitTable

import 'package:flutter_pcgen/src/core/kit/base_kit.dart';
import 'package:flutter_pcgen/src/core/kit/kit_gear.dart';

/// A kit component that stores a random-roll table mapping numeric ranges
/// to KitGear entries.
class KitTable extends BaseKit {
  String? tableName;
  final List<TableEntry> _list = [];

  String? getTableName() => tableName;
  void setTableName(String name) => tableName = name;

  void addGear(KitGear gear, dynamic minFormula, dynamic maxFormula) {
    _list.add(TableEntry(gear, minFormula, maxFormula));
  }

  List<TableEntry> getList() => List.unmodifiable(_list);

  /// Returns the first entry whose range contains [value], or null.
  KitGear? getEntry(dynamic pc, int value) {
    for (final entry in _list) {
      if (entry.isIn(pc, value)) return entry.gear;
    }
    return null;
  }

  @override
  void apply(dynamic aPC) =>
      throw UnsupportedError('KitTable.apply() is not supported');

  @override
  bool testApply(dynamic aKit, dynamic aPC, List<String> warnings) =>
      throw UnsupportedError('KitTable.testApply() is not supported');

  @override
  String getObjectName() => 'Table';
}

/// A single row in a KitTable, mapping a Formula range to a KitGear entry.
class TableEntry {
  final KitGear gear;
  final dynamic lowRange;
  final dynamic highRange;

  TableEntry(this.gear, this.lowRange, this.highRange);

  /// Returns true if [inValue] falls within the resolved range.
  bool isIn(dynamic pc, int inValue) {
    final lv = (lowRange.resolve(pc, '') as num).toInt();
    final hv = (highRange.resolve(pc, '') as num).toInt();
    return inValue >= lv && inValue <= hv;
  }
}
