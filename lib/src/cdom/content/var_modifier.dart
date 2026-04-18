import '../../formula/solver/modifier.dart';

// A modifier applied to a variable (MODIFY: token).
class VarModifier<T> {
  final String varName;
  final Modifier<T> modifier;

  const VarModifier(this.varName, this.modifier);
}
