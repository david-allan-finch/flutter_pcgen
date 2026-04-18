// Translation of pcgen.output.model.GlobalVarModel

/// Output model for a global variable value.
class GlobalVarModel {
  final dynamic _value;
  GlobalVarModel(this._value);
  @override
  String toString() => _value?.toString() ?? '';
}
