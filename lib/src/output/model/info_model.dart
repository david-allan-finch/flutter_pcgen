// Translation of pcgen.output.model.InfoModel

/// Output model for INFO data on a CDOMObject.
class InfoModel {
  final String _key;
  final dynamic _value;

  InfoModel(this._key, this._value);

  String get key => _key;
  dynamic get value => _value;

  @override
  String toString() => _value?.toString() ?? '';
}
