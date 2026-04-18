import 'identified.dart';
import 'implemented_scope.dart';
import 'var_scoped.dart';

abstract interface class ScopeInstance implements Identified {
  ImplementedScope getImplementedScope();
  VarScoped getOwningObject(ImplementedScope scope);
}
