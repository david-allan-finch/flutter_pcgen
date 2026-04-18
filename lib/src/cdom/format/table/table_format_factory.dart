// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.format.table.TableFormatFactory

import 'table_format_manager.dart';

/// Builds TableFormatManager objects for a given lookup column sub-format name.
class TableFormatFactory {
  final dynamic tableFormat;

  TableFormatFactory(this.tableFormat);

  /// Builds a TableFormatManager for the given sub-format name.
  TableFormatManager build(String subFormatName, dynamic library) {
    if (subFormatName.toUpperCase().contains('TABLE[')) {
      throw ArgumentError(
          'Multidimensional Table format not supported: $subFormatName may not contain brackets');
    }
    return TableFormatManager(tableFormat, library.getFormatManager(subFormatName));
  }

  String get builderBaseFormat => 'TABLE';
}
