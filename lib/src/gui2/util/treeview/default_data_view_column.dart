// Translation of pcgen.gui2.util.treeview.DefaultDataViewColumn

import 'data_view_column.dart';

/// Default implementation of DataViewColumn.
class DefaultDataViewColumn implements DataViewColumn {
  final String _header;
  final Type _dataClass;
  final bool _visible;
  final bool _editable;
  final double _preferredWidth;

  const DefaultDataViewColumn(
    this._header, {
    Type dataClass = String,
    bool visible = true,
    bool editable = false,
    double preferredWidth = 100.0,
  })  : _dataClass = dataClass,
        _visible = visible,
        _editable = editable,
        _preferredWidth = preferredWidth;

  @override
  String getHeaderValue() => _header;

  @override
  Type getDataClass() => _dataClass;

  @override
  bool isVisible() => _visible;

  @override
  bool isEditable() => _editable;

  @override
  double getPreferredWidth() => _preferredWidth;
}
