// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.format.table.TableFormatManager

import 'package:flutter_pcgen/src/cdom/format/table/data_table.dart';

/// A FormatManager for DataTable objects, scoped to a specific lookup column format.
class TableFormatManager {
  final dynamic tableFormat;
  final dynamic lookupFormat;

  TableFormatManager(this.tableFormat, this.lookupFormat);

  DataTable convert(String inputStr) => tableFormat.convert(inputStr) as DataTable;

  dynamic convertIndirect(String inputStr) => tableFormat.convertIndirect(inputStr);

  String unconvert(DataTable table) => table.getKeyName();

  Type get managedClass => DataTable;

  String get identifierType => 'TABLE[${lookupFormat.identifierType}]';

  dynamic get componentManager => null;

  @override
  bool operator ==(Object other) =>
      other is TableFormatManager && lookupFormat == other.lookupFormat;

  @override
  int get hashCode => lookupFormat.hashCode + 33;
}
