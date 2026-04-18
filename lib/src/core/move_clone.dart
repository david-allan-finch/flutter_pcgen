import '../cdom/enumeration/movement_type.dart';

// Represents a movement type that is cloned from another type,
// with a formula-based conversion factor.
class MoveClone {
  final MovementType _baseMovementType;
  final MovementType _cloneMovementType;
  final double Function(double) _conversion;
  final String _formulaString;

  MoveClone(MovementType base, MovementType clone,
      double Function(double) conversion, String formulaString)
      : _baseMovementType = base,
        _cloneMovementType = clone,
        _conversion = conversion,
        _formulaString = formulaString;

  MovementType getBaseType() => _baseMovementType;
  MovementType getCloneType() => _cloneMovementType;
  String getFormulaString() => _formulaString;
  double apply(double baseMove) => _conversion(baseMove);
}
