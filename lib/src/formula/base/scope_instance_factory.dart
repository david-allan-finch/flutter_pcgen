import 'package:flutter_pcgen/src/formula/base/scope_instance.dart';
import 'package:flutter_pcgen/src/formula/base/var_scoped.dart';

abstract interface class ScopeInstanceFactory {
  ScopeInstance get(String scopeName, VarScoped varScoped);
}
