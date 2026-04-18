// Translation of pcgen.output.model.UnitSetModel

/// Output model for a UnitSet (unit conversion factors for a game mode).
class UnitSetModel {
  final dynamic _unitSet;
  UnitSetModel(this._unitSet);
  @override
  String toString() => _unitSet?.toString() ?? '';
}
