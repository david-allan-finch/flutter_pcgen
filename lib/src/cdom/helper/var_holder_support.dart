// Standard implementation of VarHolder / VarContainer via delegation.
class VarHolderSupport {
  List<dynamic>? _modifierList; // List<VarModifier<?>>
  List<dynamic>? _remoteModifierList; // List<RemoteModifier<?>>
  List<String>? _grantedVars;

  void addModifier(dynamic vm) {
    _modifierList ??= [];
    _modifierList!.add(vm);
  }

  List<dynamic> getModifierArray() => _modifierList ?? const [];

  void addRemoteModifier(dynamic vm) {
    _remoteModifierList ??= [];
    _remoteModifierList!.add(vm);
  }

  List<dynamic> getRemoteModifierArray() => _remoteModifierList ?? const [];

  void addGrantedVariable(String variableName) {
    _grantedVars ??= [];
    _grantedVars!.add(variableName);
  }

  List<String> getGrantedVariableArray() => _grantedVars ?? const [];
}
