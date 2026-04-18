// Translation of pcgen.output.model.CNAbilitySelectionModel

/// Output model wrapping a CNAbilitySelection.
class CNAbilitySelectionModel {
  final String _charId;
  final dynamic _selection;

  CNAbilitySelectionModel(this._charId, this._selection);

  @override
  String toString() => _selection?.toString() ?? '';
}
