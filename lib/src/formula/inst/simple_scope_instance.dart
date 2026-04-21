import 'package:flutter_pcgen/src/formula/base/identified.dart';
import 'package:flutter_pcgen/src/formula/base/implemented_scope.dart';
import 'package:flutter_pcgen/src/formula/base/scope_instance.dart';
import 'package:flutter_pcgen/src/formula/base/var_scoped.dart';

class SimpleScopeInstance implements ScopeInstance {
  final ImplementedScope _scope;
  final VarScoped? _owner;
  final ScopeInstance? _parent;

  SimpleScopeInstance(this._scope, this._owner, [this._parent]);

  @override
  ImplementedScope getImplementedScope() => _scope;

  @override
  VarScoped getOwningObject(ImplementedScope scope) {
    if (scope == _scope) {
      return _owner!;
    }
    if (_parent != null) {
      return _parent!.getOwningObject(scope);
    }
    throw ArgumentError('No owner found for scope: ${scope.getName()}');
  }

  @override
  String getIdentification() => _scope.getName();

  @override
  String toString() => 'ScopeInstance(${_scope.getName()})';
}
