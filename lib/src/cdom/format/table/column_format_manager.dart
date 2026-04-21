// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.format.table.ColumnFormatManager

import 'package:flutter_pcgen/src/cdom/format/table/table_column.dart';

/// A FormatManager for TableColumn objects with a specific underlying column format.
class ColumnFormatManager<T> {
  final dynamic columnFormat;
  final dynamic underlying;

  ColumnFormatManager(this.columnFormat, this.underlying);

  TableColumn convert(String inputStr) => columnFormat.convert(inputStr) as TableColumn;

  dynamic convertIndirect(String inputStr) => columnFormat.convertIndirect(inputStr);

  String unconvert(TableColumn table) => table.getName() ?? '';

  Type get managedClass => TableColumn;

  String get identifierType => 'COLUMN[${underlying.identifierType}]';

  dynamic get componentManager => underlying;

  bool get isDirect => false;

  @override
  bool operator ==(Object other) =>
      other is ColumnFormatManager && underlying == other.underlying;

  @override
  int get hashCode => underlying.hashCode ^ 29;
}
