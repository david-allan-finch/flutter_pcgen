import 'scope_instance.dart';

abstract interface class VarScoped {
  ScopeInstance? getScopeInstance();
  String getKeyName();
}
