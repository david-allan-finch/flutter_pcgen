// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.format.table.ColumnFormatFactory

import 'column_format_manager.dart';

/// Builds ColumnFormatManager objects for a given column sub-format name.
class ColumnFormatFactory {
  final dynamic columnFormat;

  ColumnFormatFactory(this.columnFormat);

  /// Builds a ColumnFormatManager for the given sub-format name.
  ColumnFormatManager build(String subFormatName, dynamic library) {
    if (subFormatName.toUpperCase().contains('COLUMN[')) {
      throw ArgumentError(
          'Column Subformat not supported: $subFormatName may not contain COLUMN inside COLUMN');
    }
    final formatManager = library.getFormatManager(subFormatName);
    return ColumnFormatManager(columnFormat, formatManager);
  }

  String get builderBaseFormat => 'COLUMN';
}
