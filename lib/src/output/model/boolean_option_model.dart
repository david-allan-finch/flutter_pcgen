// Translation of pcgen.output.model.BooleanOptionModel

/// Output model for a boolean preference option.
class BooleanOptionModel {
  final String _pref;
  final bool _defaultValue;

  BooleanOptionModel(this._pref, this._defaultValue);

  bool get value {
    // TODO: read from PCGen preferences system
    return _defaultValue;
  }

  @override
  String toString() => value.toString();
}
