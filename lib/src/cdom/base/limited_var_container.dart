import 'var_container.dart';

// LimitedVarContainer is a VarContainer with identity information that can be
// used to limit the objects a token should impact.
abstract interface class LimitedVarContainer implements VarContainer {
  String getIdentifier();
  String getKeyName();
}
