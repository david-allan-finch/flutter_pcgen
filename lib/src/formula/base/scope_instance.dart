import 'package:flutter_pcgen/src/formula/base/identified.dart';
import 'package:flutter_pcgen/src/formula/base/implemented_scope.dart';
import 'package:flutter_pcgen/src/formula/base/var_scoped.dart';

abstract interface class ScopeInstance implements Identified {
  ImplementedScope getImplementedScope();
  VarScoped getOwningObject(ImplementedScope scope);
}
