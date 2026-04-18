import 'scope_instance.dart';
import 'var_scoped.dart';

abstract interface class ScopeInstanceFactory {
  ScopeInstance get(String scopeName, VarScoped varScoped);
}
