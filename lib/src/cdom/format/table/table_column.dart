// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.format.table.TableColumn

import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

/// A TableColumn is a name/format pair indicating a column within a DataTable.
class TableColumn implements Loadable {
  String? _sourceUri;
  String? _name;
  dynamic _formatManager;

  void setFormatManager(dynamic formatManager) {
    _formatManager = formatManager;
  }

  dynamic getFormatManager() => _formatManager;

  @override
  void setName(String name) => _name = name;

  String? getName() => _name;

  @override
  String getKeyName() => _name ?? '';

  @override
  String getDisplayName() => _name ?? '';

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;
}
