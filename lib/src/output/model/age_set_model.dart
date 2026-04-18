// Translation of pcgen.output.model.AgeSetModel

/// Output model wrapping an AgeSet — returns its key name as a string.
class AgeSetModel {
  final dynamic _ageSet;
  AgeSetModel(this._ageSet);
  String get asString => _ageSet?.getKeyName() ?? '';
  @override
  String toString() => asString;
}
