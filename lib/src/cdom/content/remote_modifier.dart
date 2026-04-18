import 'var_modifier.dart';

// A modifier applied to a variable on a remote object (MODIFYOTHER: token).
class RemoteModifier<T> {
  final VarModifier<T> varModifier;
  final String location;

  const RemoteModifier(this.varModifier, this.location);
}
